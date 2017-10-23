#* Imports
import re
import pycook.elisp as el
lf = el.lf

#* Globals
in_xml = "res/config.xml"
out = "out"
out_lisp = out + ".lisp"
out_xml = out + ".xml"

#* Recipes
def run(recipe):
    return [
        lf("rm -f {out_lisp} {out_xml}"),
        lf("./myscript.lisp {in_xml} {out}"),
        lf("cat {out_lisp}")]
