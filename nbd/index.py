from flask import Flask, request
import os
import base64

def get_object_pos(object_num):
    file_name = object_num // 2048
    block_pos = object_num % 2048
    return file_name, block_pos

def create_index_app(base_dir=""):
    """ Create a index app """
    app = Flask(__name__)

    @app.route('/set', methods=["POST"])
    # curl 127.0.0.1:8000/set -X POST -d "data=test"
    def handle_set():
        body = request.form
        name = body["name"]
        object_num = body["object_num"]
        data = base64.urlsafe_b64decode(body["data"])

        if not os.path.exists(os.path.join(base_dir, name)):
            os.mkdir(os.path.join(base_dir, name))

        obj_file, obj_pos = get_object_pos(int(object_num))
        path = os.path.join(base_dir, name, str(obj_file).zfill(10))

        try:
            # block_f = os.open(self.object_name(object_num), os.O_RDWR | os.O_CREAT | os.O_SYNC)
            block_f = os.open(path, os.O_RDWR | os.O_CREAT)
            os.lseek(block_f, obj_pos * (128 * 1024 + 32), os.SEEK_SET)
            os.write(block_f, data)
            os.close(block_f)
        except Exception:
            return "Failed", 500
        return "Success", 200

    @app.route('/get', methods=["POST"])
    def handle_get():
        body = request.form
        name = body["name"]
        object_num = body["object_num"]

        obj_file, obj_pos = get_object_pos(int(object_num))
        path = os.path.join(base_dir, name, str(obj_file).zfill(10))

        if not os.path.exists(path):
            return "Miss", 404
        try:
            with open(path, 'rb') as f:
                f.seek(obj_pos * (128 * 1024 + 32))
                data = f.read()
                ret = base64.urlsafe_b64encode(data)
                return ret.decode(), 200
        except Exception:
            return "Failed", 500

    return app
