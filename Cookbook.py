#* Recipes
def run(recipe):
    return [
        "rm -f out.lisp out.xml",
        "./xlx.lisp res/config.xml out.lisp",
        "./xlx.lisp out.lisp out.xml",
        "diff -s res/config.xml out.xml"]
