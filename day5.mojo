from common.stringvector import StringVector
from common.io import get_contents
from common.iter import iter
from common.parsing import ints
from common.sorting import selection_sort
from math import max, min

@register_passable("trivial")
struct Mapping(CollectionElement):
    var dst: Int
    var src: Int
    var len: Int
    fn __init__(dst: Int, src: Int, len: Int) -> Self:
        return Self {dst: dst, src: src, len: len}
    fn __init__(data: String) raises -> Self:
        let parts = data.split(" ")
        return Self {dst: atol(parts[0]), src: atol(parts[1]), len: atol(parts[2])}

@register_passable("trivial")
struct Range(CollectionElement):
    var st: Int
    var len: Int
    fn __init__(st: Int, len: Int) -> Self:
        return Self {st: st, len: len}

fn get_ranges(data: String) raises -> DynamicVector[Range]:
    var rans = DynamicVector[Range]()
    let vals = ints(data)
    for i in range(len(vals) // 2):
        rans.append(Range(vals[i*2], vals[i*2+1]))
    return rans

fn advance_single(seed: Int, maps: DynamicVector[Mapping]) raises -> Int:
    for ran in iter(maps):
        let ran_end = ran.src + ran.len # exclusive
        if ran.src <= seed < ran_end: # in range
            return ran.dst + (seed - ran.src)
    return seed

# Might split and create new ranges
fn advance_range(ranges: DynamicVector[Range], maps: DynamicVector[Mapping]) raises -> DynamicVector[Range]:
    return ranges # TODO!

fn solve() raises -> String:
    let blocks: DynamicVector[String] = get_contents("inputs/day5.txt").split("\n\n")

    var state1: DynamicVector[Int] = ints(blocks[0]) # part1
    var state2: DynamicVector[Range] = get_ranges(blocks[0]) # part2

    # Loop through maps, advance state
    for i in range(1, len(blocks)):
        # Read next mapping
        var maps = DynamicVector[Mapping]()
        let lines = blocks[i].split("\n")
        for i in range(1, len(lines)):
            maps.push_back(Mapping(lines[i]))
        
        # Advance state (part1)
        for i in range(len(state1)):
            state1[i] = advance_single(state1[i], maps)

        # Advance state (part2)
        state2 = advance_range(state2, maps)

    # Return lowest
    selection_sort(state1)
    let sol_part1 = state1[0]

    return String(state1[0]) # 3374647
