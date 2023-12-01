from python import Python
from .stringvector import StringVector

fn get_contents(infile: String) -> String:
    try:
        return open(infile, "r").read()
    except:
        return ""

fn get_lines(infile: String) -> StringVector:
    var ret = StringVector()
    var curr_str: String = ""
    let contents = get_contents(infile)
    for i in range(len(contents)):
        let c = contents[i]
        if c == "\n":
            ret.push_back(curr_str)
            curr_str = ""
        else:
            curr_str += c
    if curr_str != "":
        ret.push_back(curr_str)

    return ret^ # transfer ownership
