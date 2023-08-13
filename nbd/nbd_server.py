#!/usr/bin/env python
""" This is a modified NBD server based on https://github.com/reidrac/swift-nbd-server """
import os
import logging
import errno
import struct
import signal
import asyncio
import base64
# import time
import requests
from argparse import ArgumentParser
from collections import Counter
# from time import time
from hashlib import sha256

VERSION = "0.12"
DESCRIPTION = "This is a NBD proxy server."
BASE_PROJECT_URL = "https://github.com/reidrac/swift-nbd-server"
STATS_DELAY = 300

OBJECT_SIZE = 128 * 1024 # 128KB


def set_log(debug=False, use_file=None):
    """ Get a logger """
    log = logging.getLogger(__package__)

    if use_file:
        handler = logging.FileHandler(use_file)
    else:
        handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter('%(asctime)s: %(name)s: %(levelname)s: %(message)s'))

    log.addHandler(handler)
    if debug:
        log.setLevel(logging.DEBUG)
        log.debug("Verbose log enabled")
    else:
        log.setLevel(logging.INFO)

    return log

class AbortedNegotiationError(IOError):
    """ Error during NBD negotiation """

class StorageError(IOError):
    """ Error in backend storage """
    def __init__(self, err, ex):
        super(StorageError, self).__init__(err, "Storage error: %s", ex)

class Stats(object):
    """ Print stats periodically """
    def __init__(self, store):
        self.store = store

        self.bytes_in = 0
        self.bytes_out = 0
        self.log = logging.getLogger(__package__)

    def log_stats(self):
        """Log stats."""
        self.log.info(
            "STATS: %s in=%s (%s), out=%s (%s)",
            self.store,
            self.bytes_in,
            self.store.bytes_out,
            self.bytes_out,
            self.store.bytes_in
        )

        cache = len(self.store.cache) * self.store.object_size
        limit = self.store.cache.limit * self.store.object_size
        self.log.info(
            "CACHE: %s size=%s, limit=%s (%.2f%%)",
            self.store,
            cache, limit,
            (cache*100.0/limit)
        )
        self.log.info(
            "CACHE: %s read_hit=%s, read_miss=%s, write_set=%s, cache_free=%s",
            self.store,
            self.store.cache.hit_miss['read_hit'],
            self.store.cache.hit_miss['read_miss'],
            self.store.cache.hit_miss['write_set'],
            self.store.cache.hit_miss['cache_free'],
        )

class Cache(object):
    """ Cache data in memory """
    def __init__(self, limit: int):
        # Limit is in object numbers
        self.limit = limit
        self.ref = Counter()
        self.data = dict()
        self.data_checksum = dict()
        self.hit_miss = Counter()
        # read_hit
        # read_miss
        # write_set
        # cache_free
        self.log = logging.getLogger(__package__)
        self.log.info("cache size: %s", self.limit)

    def __len__(self):
        return len(self.data)

    def get(self, object_name, default=None):
        """Get an element from the cache"""
        if self.ref[object_name] > 0:
            self.ref[object_name] += 1

            self.log.debug("cache hit: %s, %s", object_name, self.ref[object_name])
            self.hit_miss["read_hit"] += 1
            if sha256(self.data[object_name]).digest() != self.data_checksum[object_name]:
                self.log.warning("Checksum error in cache !!")
                del self.ref[object_name]
                del self.data[object_name]
                del self.data_checksum[object_name]
                return None
            return self.data[object_name]

        self.log.debug("cache miss: %s, %s", object_name, self.ref[object_name])
        self.hit_miss["read_miss"] += 1
        return default

    def set(self, object_name, data, checksum):
        """Put/update an element in the cache"""
        self.data[object_name] = data
        self.data_checksum[object_name] = checksum
        self.ref[object_name] += 1

        self.log.debug("cache set: %s, %s", object_name, self.ref[object_name])
        self.hit_miss["write_set"] += 1

        if len(self.data) > self.limit:
            self.log.debug("cache size is over limit (%s > %s)", len(self.data), self.limit)
            less_used = self.ref.most_common()[:-3:-1]
            for key, _ in less_used:
                if object_name != key:
                    self.log.debug("cache free: %s, %s", key, self.ref[key])
                    self.hit_miss["cache_free"] += 1
                    del self.ref[key]
                    del self.data[key]
                    del self.data_checksum[key]
                    break

    def flush(self):
        """Flush the cache"""
        self.log.debug("cache flush, was (%s): %s", len(self.data), self.ref)
        self.ref = Counter()
        self.data = dict()

class ObjStorage(object):
    """ Backend storage """
    def __init__(self, container, object_size, objects, cache: Cache, addr, read_only=False):
        # container is the prefix name to store actual data
        self.container = container
        self.lock_file = f"{self.container}.lock"
        # object_size is size for single object
        self.object_size = object_size
        # objects is total number of objects
        self.objects = objects
        self.pos = 0
        self.meta = dict()
        self.read_only = read_only
        self.locked = False

        self.bytes_in = 0
        self.bytes_out = 0

        self.cache = cache
        self.session = requests.session()

        self.remote_address = addr

    def __str__(self):
        return self.container

    def lock(self) -> bool:
        """ Prevent further access to backend storage """
        if os.path.exists(self.lock_file):
            return False
        with open(self.lock_file, 'w+', encoding="utf8") as lock_f:
            lock_f.write("")
            self.locked = True
        return True

    def unlock(self):
        """ Unlock """
        self.locked = False
        os.remove(self.lock_file)

    def seek(self, offset):
        """ Seek to another position """
        if offset < 0 or offset > self.size:
            raise StorageError(errno.ESPIPE, "Offset out of bounds")
        self.pos = offset

    def read(self, size):
        """ Read data from backend storage """
        data = bytearray()
        # remaining bytes to read
        _size = size
        while _size > 0:
            obj = self.fetch_object(self.object_num)
            if obj == b'':
                break

            if _size + self.object_pos >= self.object_size:
                # need more than this obj
                data += obj[self.object_pos:]
                part_size = self.object_size - self.object_pos
            else:
                # can be satisfied by this obj
                data += obj[self.object_pos:self.object_pos+_size]
                part_size = _size

            _size -= part_size
            self.seek(self.pos + part_size)
        return data

    def write(self, data):
        """ Write data to backend storage """
        if self.read_only:
            raise StorageError(errno.EROFS, "Read only storage")

        _data = data[:]
        if self.object_pos != 0:
            # object-align the beginning of data
            obj = self.fetch_object(self.object_num)
            _data = obj[:self.object_pos] + _data
            self.seek(self.pos - self.object_pos)

        reminder = len(_data) % self.object_size
        if reminder != 0:
            # object-align the end of data
            obj = self.fetch_object(self.object_num + (len(_data) // self.object_size))
            _data += obj[reminder:]

        assert len(_data) % self.object_size == 0, "Data not aligned!"

        offs = 0
        object_num = self.object_num
        while offs < len(_data):
            self.put_object(object_num, _data[offs:offs+self.object_size])
            offs += self.object_size
            object_num += 1

    def tell(self):
        """ Show current cursor position """
        return self.pos

    @property
    def object_pos(self):
        """ Show position inside object """
        return self.pos % self.object_size

    @property
    def object_num(self):
        """ Show object number based on position """
        return self.pos // self.object_size

    @property
    def size(self):
        """ Show backend size """
        return self.object_size * self.objects

    def flush(self):
        """ Flush dirty data """

    def object_name(self, object_num):
        """ Show object name by num """
        return f"disk.{self.container}.part/{str(object_num).zfill(12)}"

    def fetch_object(self, object_num):
        """ Fetch a block by object_num """
        if object_num >= self.objects:
            return b''

        data = self.cache.get(object_num)
        if data is not None:
            # cache hit, return directly
            return data

        # cache miss, try to read from store
        post_data = {
            "name": self.container,
            "object_num": object_num
        }
        try:
            r = self.session.post(f"{self.remote_address}/get", data=post_data)
            if r.status_code == 404:
                # store miss, return all zero
                data = b'\0' * self.object_size
                return data
            if r.status_code == 500:
                raise StorageError(errno.ESPIPE, "Failed to read data")
            if r.status_code == 200:
                data = base64.urlsafe_b64decode(r.text)
                if sha256(data[32:]).digest() != data[:32]:
                    raise StorageError(errno.ESPIPE, "Failed to verify data")
                self.cache.set(object_num, data[32:], data[:32])
                return data[32:]
        except Exception as ex:
            raise StorageError(errno.ESPIPE, "Failed to read data") from ex

    def put_object(self, object_num, data):
        """ Write a block """
        if object_num >= self.objects:
            raise StorageError(errno.ESPIPE, "Write offset out of bounds")

        checksum = sha256(data).digest()
        self.bytes_out += self.object_size
        self.cache.set(object_num, data, checksum)

        post_data = {
            "name": self.container,
            "object_num": object_num,
            "data": base64.urlsafe_b64encode(checksum + data).decode()
        }

        try:
            r = self.session.post(f"{self.remote_address}/set", data=post_data)
            if r.status_code == 500:
                raise StorageError(errno.ESPIPE, "Failed to write data")
            if r.status_code == 200:
                pass
        except Exception as ex:
            raise StorageError(errno.ESPIPE, "failed to write object: " + str(ex)) from ex

class Server(object):
    """ A NBD Server """
    NBD_HANDSHAKE = 0x49484156454F5054
    NBD_REPLY = 0x3e889045565a9

    NBD_REQUEST = 0x25609513
    NBD_RESPONSE = 0x67446698

    NBD_OPT_EXPORTNAME = 1
    NBD_OPT_ABORT = 2
    NBD_OPT_LIST = 3

    NBD_REP_ACK = 1
    NBD_REP_SERVER = 2
    NBD_REP_ERR_UNSUP = 2**31 + 1

    NBD_CMD_READ = 0
    NBD_CMD_WRITE = 1
    NBD_CMD_DISC = 2
    NBD_CMD_FLUSH = 3

    # fixed newstyle handshake
    NBD_HANDSHAKE_FLAGS = 1 << 0

    # has flags, supports flush
    NBD_EXPORT_FLAGS = (1 << 0) ^ (1 << 2)
    NBD_RO_FLAG = 1 << 1

    def __init__(self, addr, stores):
        self.log = logging.getLogger(__package__)

        self.address = addr
        self.stores = stores

        self.stats = dict()
        for store in self.stores.values():
            self.stats[store] = Stats(store)

    async def log_stats(self):
        """ Log stats periodically"""
        while True:
            for stats in self.stats.values():
                stats.log_stats()

            await asyncio.sleep(STATS_DELAY)

    async def nbd_response(self, writer, handle, error=0, data=None):
        """ Write a NBD response """
        writer.write(struct.pack('>LLQ', self.NBD_RESPONSE, error, handle))
        if data:
            writer.write(data)
        await writer.drain()

    async def handler(self, reader, writer):
        """ Handle a single NBD connection """
        try:
            host, port = writer.get_extra_info("peername")
            store, container = None, None
            self.log.info("Incoming connection from %s:%s", host, port)

            # initial handshake
            writer.write(b"NBDMAGIC" + struct.pack(
                ">QH",
                self.NBD_HANDSHAKE,
                self.NBD_HANDSHAKE_FLAGS
            ))
            await writer.drain()

            data = await reader.readexactly(4)
            try:
                client_flag = struct.unpack(">L", data)[0]
                self.log.debug("Client flag: %s", client_flag)
            except struct.error as exc:
                raise IOError("Handshake failed, disconnecting") from exc

            # we support both fixed and unfixed new-style handshake
            if client_flag == 0:
                fixed = False
                self.log.warning("Client using new-style non-fixed handshake")
            elif client_flag & 1:
                fixed = True
                self.log.info("Client using new-style fixed handshake")
            else:
                raise IOError("Handshake failed, disconnecting")

            # negotiation phase
            while True:
                header = await reader.readexactly(16)
                try:
                    (magic, opt, length) = struct.unpack(">QLL", header)
                except struct.error as ex:
                    raise IOError("Negotiation failed: Invalid request, disconnecting") from ex

                if magic != self.NBD_HANDSHAKE:
                    raise IOError(f"Negotiation failed: bad magic number: {magic}")

                if length:
                    data = await reader.readexactly(length)
                    if len(data) != length:
                        raise IOError(f"Negotiation failed: {length} bytes expected")
                else:
                    data = None

                self.log.debug(
                    "[%s:%s]: opt=%s, len=%s, data=%s",
                    host, port, opt, length, data
                )

                if opt == self.NBD_OPT_EXPORTNAME:
                    if not data:
                        raise IOError("Negotiation failed: no export name was provided")

                    data = data.decode("utf-8")
                    if data not in self.stores:
                        if not fixed:
                            raise IOError("Negotiation failed: unknown export name")

                        writer.write(
                            struct.pack(">QLLL", self.NBD_REPLY, opt, self.NBD_REP_ERR_UNSUP, 0)
                        )
                        await writer.drain()
                        continue

                    # we have negotiated a store and it will be used
                    # until the client disconnects
                    store = self.stores[data]
                    if not store.lock():
                        raise IOError("Failed to lock export")

                    self.log.info("[%s:%s] Negotiated export: %s", host, port, store.container)

                    export_flags = self.NBD_EXPORT_FLAGS
                    if store.read_only:
                        export_flags ^= self.NBD_RO_FLAG
                        self.log.info("[%s:%s] %s is read only", host, port, store.container)
                    writer.write(struct.pack('>QH', store.size, export_flags))

                    writer.write(b"\x00"*124)
                    await writer.drain()

                    break

                elif opt == self.NBD_OPT_LIST:
                    for container in self.stores.keys():
                        writer.write(
                            struct.pack(">QLLL",
                                        self.NBD_REPLY, opt,
                                        self.NBD_REP_SERVER,
                                        len(container) + 4
                            ))
                        container_encoded = container.encode("utf-8")
                        writer.write(struct.pack(">L", len(container_encoded)))
                        writer.write(container_encoded)
                        await writer.drain()

                    writer.write(struct.pack(">QLLL", self.NBD_REPLY, opt, self.NBD_REP_ACK, 0))
                    await writer.drain()

                elif opt == self.NBD_OPT_ABORT:
                    writer.write(struct.pack(">QLLL", self.NBD_REPLY, opt, self.NBD_REP_ACK, 0))
                    await writer.drain()
                    raise AbortedNegotiationError()

                else:
                    # we don't support any other option
                    if not fixed:
                        raise IOError("Unsupported option")

                    writer.write(
                        struct.pack(">QLLL",
                                    self.NBD_REPLY,
                                    opt,
                                    self.NBD_REP_ERR_UNSUP,
                                    0
                        ))
                    await writer.drain()

            # operation phase
            while True:
                header = await reader.readexactly(28)
                try:
                    (magic, cmd, handle, offset, length) = struct.unpack(">LLQQL", header)
                except struct.error as ex:
                    raise IOError("Invalid request, disconnecting") from ex

                if magic != self.NBD_REQUEST:
                    raise IOError("Bad magic number, disconnecting")

                if cmd == self.NBD_CMD_WRITE:
                    cmd_literal = "WRITE"
                elif cmd == self.NBD_CMD_READ:
                    cmd_literal = "READ"
                elif cmd == self.NBD_CMD_FLUSH:
                    cmd_literal = "FLUSH"

                self.log.debug(
                    "[%s:%s]: cmd=%s, handle=%s, offset=%s, len=%s, block=%s",
                    host, port,
                    cmd_literal, handle,
                    offset, length, offset // OBJECT_SIZE
                )

                if cmd == self.NBD_CMD_DISC:
                    self.log.info("[%s:%s] disconnecting", host, port)
                    break

                elif cmd == self.NBD_CMD_WRITE:
                    data = await reader.readexactly(length)
                    if len(data) != length:
                        raise IOError(f"{length} bytes expected, disconnecting")

                    try:
                        store.seek(offset)
                        store.write(data)
                    except IOError as ex:
                        self.log.error("[%s:%s] %s", host, port, ex)
                        await self.nbd_response(writer, handle, error=ex.errno)
                        continue

                    self.stats[store].bytes_in += length
                    await self.nbd_response(writer, handle)

                elif cmd == self.NBD_CMD_READ:
                    try:
                        store.seek(offset)
                        data = store.read(length)
                    except IOError as ex:
                        self.log.error("[%s:%s] %s", host, port, ex)
                        await self.nbd_response(writer, handle, error=ex.errno)
                        continue

                    if data:
                        self.stats[store].bytes_out += len(data)
                    await self.nbd_response(writer, handle, data=data)

                elif cmd == self.NBD_CMD_FLUSH:
                    self.log.debug("Got flush")
                    store.flush()
                    await self.nbd_response(writer, handle)

                else:
                    self.log.warning("[%s:%s] Unknown cmd %s, disconnecting", host, port, cmd)
                    break

        except AbortedNegotiationError:
            self.log.info("[%s:%s] Client aborted negotiation", host, port)

        except (asyncio.IncompleteReadError, IOError) as ex:
            self.log.error("[%s:%s] %s", host, port, ex)

        finally:
            if store:
                try:
                    store.unlock()
                except IOError as ex:
                    self.log.error(ex)

            writer.close()

        self.log.debug("Handler func exit")

    def unlock_all(self):
        """Unlock any locked storage."""
        for store in self.stores.values():
            if store.locked:
                self.log.debug("%s: Unlocking storage...", store)
                store.unlock()

    def serve_forever(self):
        """Create and run the asyncio loop"""
        addr, port = self.address

        loop = asyncio.get_event_loop()
        stats = loop.create_task(self.log_stats())

        server_coro = asyncio.start_server(self.handler, addr, port)
        server = loop.run_until_complete(server_coro)

        self.log.info("Listening signals...")
        loop.add_signal_handler(signal.SIGTERM, loop.stop)
        loop.add_signal_handler(signal.SIGINT, loop.stop)

        loop.run_forever()

        self.log.info("Server is shutting down...")

        stats.cancel()
        server.close()
        loop.run_until_complete(server.wait_closed())
        loop.close()

class Main(object):
    """ Main class """
    def __init__(self):

        parser = ArgumentParser(
            description=DESCRIPTION,
            epilog=f"Contact and support: {BASE_PROJECT_URL}"
        )

        parser.add_argument("--version", action="version", version="%(prog)s "  + VERSION)

        parser.add_argument("-b", "--bind-address", dest="bind_address",
                            default="127.0.0.1",
                            help="bind address (default: 127.0.0.1)")

        parser.add_argument("-r", "--remote-address", dest="remote_address",
                            default="http://127.0.0.1:8000",
                            help="remote address (default: http://127.0.0.1:8000)")

        parser.add_argument("-n", "--name", dest="name",
                            default="test-nbd",
                            help="name of block (default: test-nbd)")

        parser.add_argument("-p", "--bind-port", dest="bind_port",
                            type=int,
                            default=10809,
                            help="bind address (default: 10809)")

        parser.add_argument("-c", "--cache-limit", dest="cache_limit",
                            type=int,
                            default=64,
                            help="cache memory limit in MB (default: 64)")

        parser.add_argument("-l", "--log-file", dest="log_file",
                            default=None,
                            help="log into the provided file"
                            )

        parser.add_argument("-v", "--verbose", dest="verbose",
                            action="store_true",
                            help="enable verbose logging"
                            )

        self.args = parser.parse_args()

        if self.args.cache_limit < 1:
            parser.error("Cache limit can't be less than 1MB")

        self.log = set_log(
            debug=self.args.verbose,
            use_file=self.args.log_file
        )

    def run(self):
        """ Run forever """
        stores = dict()

        container = self.args.name
        objects = 8 * 1024 * 100 # = 100GB
        # objects = 1024
        stores[container] = ObjStorage(
            container,
            OBJECT_SIZE,
            objects,
            Cache(int(self.args.cache_limit*1024**2 / OBJECT_SIZE)),
            self.args.remote_address,
            False,
        )

        addr = (self.args.bind_address, self.args.bind_port)
        server = Server(addr, stores)

        server.serve_forever()

        server.unlock_all()

        self.log.info("Exiting...")
        return 0

if __name__ == "__main__":
    main = Main()

    # import cProfile, pstats, io
    # from pstats import SortKey
    # import sys
    # profiler = cProfile.Profile()
    # profiler.enable()

    main.run()

    # profiler.disable()
    # s = io.StringIO()
    # sortby = SortKey.CUMULATIVE
    # ps = pstats.Stats(profiler, stream=s).sort_stats(sortby)
    # ps.print_stats()
    # print(s.getvalue())
