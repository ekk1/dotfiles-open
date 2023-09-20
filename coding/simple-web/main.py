"""a simple web demo"""
from flask import Flask, request, render_template
app = Flask(__name__)

@app.route('/', methods=["GET", "POST"])
def hello_world():
    """serve root"""
    msg = ""
    if request.method == "POST":
        data = request.form
        print(data)
        if 'action' not in data:
            msg = "action is required"
        else:
            msg = "POSTED"
            msg += f"{data['action']} on {data['name_list']}"
    data = {'111': {'status': 'test'}}
    return render_template('test.html', data=data, msg=msg)

if __name__ == "__main__":
    app.run("127.0.0.1", 9099, debug=True)
