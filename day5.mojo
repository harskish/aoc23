from common.stringvector import StringVector
from common.io import get_contents
from common.iter import iter
from common.parsing import ints
from common.sorting import selection_sort
from math import max, min

fn solve() raises -> String:
    return String(part1()) + ", " + String(part2())

@register_passable("trivial")
struct Range(CollectionElement):
    var dst_start: Int
    var src_start: Int
    var src_end: Int # redundant but convenient; inclusive
    var len: Int 
    fn __init__(dst_start: Int, src_start: Int, len: Int) -> Self:
        return Self {dst_start: dst_start, src_start: src_start, src_end: src_start+len-1, len: len}

def get_range(desc: String) -> Range:
    let parts = desc.split(" ")
    return Range(atol(parts[0]), atol(parts[1]), atol(parts[2]))

fn part1() raises -> String:
    let blocks = get_contents("inputs/day5.txt").split("\n\n")

    # Loop through maps, advance state
    var state: DynamicVector[Int] = ints(blocks[0]) # current inds (initially: seeds)
    for i in range(1, len(blocks)):
        #print("Mapping", i)

        # Read next mapping
        var ranges = DynamicVector[Range]()
        let lines = blocks[i].split("\n")
        for i in range(1, len(lines)):
            ranges.push_back(get_range(lines[i]))
        
        # Advance state
        for i in range(len(state)):
            let val = state[i]
            for ran in iter(ranges):
                if ran.src_start <= val <= ran.src_end: # in range
                    state[i] = ran.dst_start + (val - ran.src_start)
                    #print(val, "->", state[i])
                    break

    # Return lowest
    selection_sort(state)
    return String(state[0]) # 3374647

fn part2() raises -> String:
    let blocks = get_contents("inputs/day5_test.txt").split("\n\n")

    # Load initial state
    var state = DynamicVector[Range]() # Abuse existing class
    let init = ints(blocks[0])
    for i in range(len(init)//2):
        let s = init[i*2]
        let len = init[i*2+1]
        state.push_back(Range(s, s, len))

    # Loop through levels (=mappings)
    for i in range(1, len(blocks)):
        print("Mapping", i)

        # Read next mapping
        var ranges = DynamicVector[Range]()
        let lines = blocks[i].split("\n")
        for i in range(1, len(lines)):
            ranges.push_back(get_range(lines[i]))
        
        # Create new ranges (replaces all previous)
        var new_ranges = DynamicVector[Range]()
        for sran in iter(state):
            for mran in iter(ranges):
                # Add left portion
                if sran.src_start <= mran.src_start <= sran.src_end:
                    # state range start to mapping range start
                    let len = mran.src_start - sran.src_start + 1
                    new_ranges.append(Range(-1, sran.src_start, len))
                    print("Adding left part", sran.src_start, "->", sran.src_start + len)
                
                # Add middle portion
                let mid_start = max(sran.src_start, mran.src_start)
                let mid_end = min(sran.src_end, mran.src_end)
                if sran.src_start != mid_start or sran.src_end != mid_end:
                    let len = mid_end - mid_start + 1
                    new_ranges.append(Range(-1, mid_start, len))
                else:
                    print("Mid part untouched")

                # Add right portion
                if sran.src_start <= mran.src_end <= sran.src_end:
                    # mapping range end to state range end
                    let len = sran.src_end - mran.src_end + 1
                    new_ranges.append(Range(-1, mran.src_end, len))
                    print("Adding right part", mran.src_end, "->", mran.src_end + len)
        
        # Advance all ranges
        state = new_ranges # replace
        for i in range(len(state)):
            let sran = state[i]
            for mran in iter(ranges):
                let contained = mran.src_start <= sran.src_start <= sran.src_end <= mran.src_end
                if contained:
                    let d = mran.dst_start - mran.src_start # offset
                    state[i] = Range(-1, sran.src_start + d, sran.len) # len unchaged
                    break

    # Return lowest
    var lowest = state[0].src_start
    for ran in iter(state):
        lowest = min(lowest, ran.src_start)
    
    return String(lowest)