from math import max, min
from .stringvector import StringVector

# Get individual digits
fn digits(input: String) -> DynamicVector[Int]:
    alias chr_lo = ord('0')
    var res = DynamicVector[Int]()
    
    for i in range(len(input)):
        let digit: Int = input._buffer[i].to_int() - chr_lo
        if 0 <= digit <= 9:
            res.push_back(digit)
    
    return res

# Extract integers
fn ints(input: String) raises -> DynamicVector[Int]:
    alias chr_lo = ord('0')
    var res = DynamicVector[Int]()
    
    var accum: String = ""
    for i in range(len(input)):
        let char = input[i]
        if isdigit(char._buffer[0].to_int()):
            accum = accum + char
        else:
            if accum != "":
                res.push_back(atol(accum))
            accum = ""
    
    if accum != "":
        res.push_back(atol(accum))
    
    return res

fn reverse(s: String) -> String:
    let slen = len(s)
    let chars = Pointer[SIMD[DType.int8, 1]].alloc(slen + 1)
    for i in range(slen):
       chars.store(i, s._buffer[slen-1-i])
    chars.store(slen, 0)
    return String(chars)

fn startswith(source: String, target: String) -> Bool:
    if len(source) < len(target):
        return False
    
    for i in range(len(target)):
        if source._buffer[i] != target._buffer[i]:
            return False
    
    return True

# Find first substring using list of candidates
# Returns:
#   i: index into source string
#   j: index of substring that was found
fn first_substr_match(source: String, inout targets: StringVector) -> Tuple[Int, Int]:
    var window_size = 0
    for s in targets:
       window_size = max(window_size, len(s))
    
    for i in range(len(source)):
        let substr = source[i:i+window_size]
        for j in range(targets.size):
            if startswith(substr, targets[j]):
                return (i, j)
    
    return (-1, -1)

# Matches python's string.split
fn split(source: String, target: String) -> StringVector:
    var ranges = DynamicVector[Tuple[Int, Int]]()
    
    var i = 0
    while True:
        let offs = source.find(target, i)
        if offs == -1:
            ranges.push_back((i, len(source)))
            break
        else:
            ranges.push_back((i, i+offs))
            i += len(target) + offs
    
    var parts = StringVector()
    for i in range(len(ranges)):
        let i1 = ranges[i].get[0, Int]()
        let i2 = ranges[i].get[1, Int]()
        parts.push_back(source[i1:i2])
    
    return parts^
