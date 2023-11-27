"""webui"""

class WebUIBase:
    """base class"""
    def __init__(self):
        self.child_list = []
        self.tag = ""
        self.attributes = {}
        self.value = ""
        self.value_end = ""
        self.end_tag = ""

    def render(self):
        """return generated html string"""
        body = ""
        for _w in self.child_list:
            body += _w.render()
        return body

    def add_child(self, _w):
        """add child component"""
        if not isinstance(_w, WebUIBase):
            raise RuntimeError(_w, "is not an valid webui")
        self.child_list.append(_w)

class WebUIButton(WebUIBase):
    """a html button"""
    def __init__(self, name):
        super().__init__()
        self.tag = "button"
        self.value = name
