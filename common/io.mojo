from .stringvector import StringVector

fn get_contents(infile: String) -> String:
    try:
        return open(infile, "r").read()
    except:
        return ""

fn get_lines(infile: String) -> StringVector:
    try:
        return open(infile, "r").read().split("\n")
    except:
        return StringVector()
