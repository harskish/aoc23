from math import max, min
from .stringvector import StringVector

# Get individual digits
fn digits(input: String) -> DynamicVector[Int]:
    alias chr_lo = ord('0')
    var res = DynamicVector[Int](len(input))
    
    for i in range(len(input)):
        let digit: Int = input._buffer[i].to_int() - chr_lo
        if 0 <= digit <= 9:
            res.push_back(digit)
    
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

# Python-esque: won't read out of bounds
fn substr(source: String, start: Int, length: Int) -> String:
    let num_chars = min(len(source) - start, length)
    let data = DTypePointer[DType.int8].alloc(num_chars + 1)
    data.store(num_chars, 0) # null terminator
    memcpy(data, source._buffer.data.offset(start), num_chars)
    return String(data)

# From start index until end
fn substr(source: String, start: Int) -> String:
    return substr(source, start, len(source))

# Find first substring using list of candidates
# Returns:
#   i: index into source string
#   j: index of substring that was found
fn first_substr_match(source: String, inout targets: StringVector) -> Tuple[Int, Int]:
    var window_size = 0
    for s in targets:
       window_size = max(window_size, len(s))
    
    for i in range(len(source)):
        let substr = substr(source, i, window_size) # won't read OOB
        for j in range(targets.size):
            if startswith(substr, targets[j]):
                return (i, j)
    
    return (-1, -1)

fn find(source: String, target: String) -> Int:
    let window = len(target)
    for i in range(len(source)):
        let ss = substr(source, i, window)
        if startswith(ss, target):
            return i
    return -1

# Matches python's string.split
fn split(source: String, target: String) -> StringVector:
    var ranges = DynamicVector[Tuple[Int, Int]]()
    
    var i = 0
    while True:
        let ss = substr(source, i)
        let offs = find(ss, target)
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
        parts.push_back(substr(source, i1, i2-i1))
    
    return parts^