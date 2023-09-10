import libtorrent
import sys
import os
import pprint
import hashlib
import binascii
import time

alter_path = "./"
t_path = sys.argv[1]
if len(sys.argv) > 2:
    alter_path = sys.argv[2]

t_info = libtorrent.torrent_info(t_path)
files_manager = t_info.files()
block_size = t_info.piece_length()
total_pieces = t_info.num_pieces()
print("BLOCK_SIZE: ", block_size)
print("TOTAL_PIECE: ", total_pieces)

files = {}          # File list
piece_files = {}    # single piece info, hash and contain files

t1 = time.time()
print("Parsing torrent file")
# Get hash for each piece
for ii in range(0, total_pieces):
    piece_files[ii] = {
        "hash": t_info.hash_for_piece(ii),
        "files": []
    }
# Get each file's info, size and offset
for ii in range(0, files_manager.num_files()):
    files[files_manager.file_path(ii)] = {
        "size": files_manager.file_size(ii),
        "offset": files_manager.file_offset(ii)
    }
# For each block, find which file it should contain, and calculate how many data it should read from this file
for ff in files:
    start_position = files[ff]["offset"]
    start_piece = start_position // block_size
    end_posision = files[ff]["offset"] + files[ff]["size"]
    end_piece = end_posision // block_size
    # print("Start at: ", start_piece, " End at: ", end_piece)
    if start_piece == end_piece:
        pp = start_piece
        file_start_byte = 0
        file_end_byte = 0
        if pp * block_size <= files[ff]["offset"]:
            file_start_byte = 0
        else:
            file_start_byte = pp * block_size - files[ff]["offset"]
        if (pp + 1) * block_size >= end_posision:
            file_end_byte = files[ff]["size"]
        else:
            file_end_byte = (pp + 1) * block_size - files[ff]["offset"]
        piece_files[pp]["files"].append({
            "fname": ff,
            "fstart": file_start_byte,
            "fend": file_end_byte,
            "fsize": files[ff]["size"]
        })
    else:
        for pp in range(start_piece, end_piece + 1):
            file_start_byte = 0
            file_end_byte = 0
            if pp * block_size <= files[ff]["offset"]:
                file_start_byte = 0
            else:
                file_start_byte = pp * block_size - files[ff]["offset"]
            if (pp + 1) * block_size >= end_posision:
                file_end_byte = files[ff]["size"]
            else:
                file_end_byte = (pp + 1) * block_size - files[ff]["offset"]
            piece_files[pp]["files"].append({
                "fname": ff,
                "fstart": file_start_byte,
                "fend": file_end_byte
            })

print("Torrent file parsed")
t2 = time.time()
print("Used", t2 - t1, "seconds")

success_pieces = 0
failed_pieces = 0
failed_info = []
for piece in piece_files:
    piece_bytes = b""
    for f in piece_files[piece]['files']:
        try:
            ff = open(alter_path + f['fname'], 'rb')
            ff.seek(f["fstart"])
            data = ff.read(f["fend"] - f["fstart"])
            ff.close()
            piece_bytes = piece_bytes + data
        except Exception as e:
            # print(f"Error while reading: {f['fname']}")
            pass

    if len(piece_bytes) != block_size and piece + 1 != total_pieces:
        # For normal pieces, if readed bytes not equal to block_size
        # this indicates incomplete byte read, which means missing file or other errors
        # print()
        # print("Piece [" + str(piece) + "/" + str(total_pieces) + "] : FAILED, incomplete read")
        failed_pieces += 1
        failed_info.append({
            "Piece": piece,
            "Files:": piece_files[piece]['files']
        })
    else:
        # This should be the last piece, just calculate what we have read
        s = hashlib.sha1()
        s.update(piece_bytes)
        if s.digest() == piece_files[piece]['hash']:
            print("\rPiece [" + str(piece) + "/" + str(total_pieces) + "] : OK", end="")
            success_pieces += 1
        else:
            print()
            print("Piece [" + str(piece + 1) + "/" + str(total_pieces) + "] : FAILED, hash mismatch")
            # print("Piece [" + str(piece + 1) + "/" + str(total_pieces) + "] : FAILED, hash mismatch")
            failed_pieces += 1
            failed_info.append({
                "Piece": piece + 1,
                "Files:": piece_files[piece]['files'],
                "Expected hash": binascii.b2a_base64(piece_files[piece]['hash']),
                "Actual Hash": binascii.b2a_base64(s.digest()),
            })

t3 = time.time()

incomplete_blocks = 0
for _info in failed_info:
    if 'Expected hash' in _info:
        print(f"Possible corrupt block: {_info['Piece']}")
        # print(f"Affecting files: {_info['Files']}")
        pprint.pprint(_info)
    else:
        # print(f"Possible missing files in: f{_info['Piece']}")
        # print(f"Affecting files: f{_info['Files']}")
        incomplete_blocks += 1

print("\n")
print("================================================================")
print(t_info.name())
print("DETAIL: ")
#pprint.pprint(failed_info)
print("TOTAL: ", total_pieces)
print("SUCCESS: ", success_pieces)
print("FAILED: ", failed_pieces)
print("INCOMPLETE: ", incomplete_blocks)

print("TOTAL SIZE: ", t_info.total_size())
print("TOTAL TIME: ", t3 - t2)
print("Approx Speed: ", t_info.total_size() / 1024 / 1024 / (t3 - t2), "MB/s")

print("================================================================")

