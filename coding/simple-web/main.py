from flask import Flask, request, render_template
app = Flask(__name__)

@app.route('/')
def hello_world():
    return render_template('test.html')

@app.route('/file', methods=['POST'])
def handle_upload():
    f = request.form
    print(f)
    return render_template('test.html')


if __name__ == "__main__":
    app.run("127.0.0.1", 9099)
