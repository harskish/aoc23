from common.stringvector import StringVector
from common.hashmap import StringMap, IntMap
from common.io import get_contents, get_lines
from common.parsing import split, ints
from common.sorting import selection_sort

fn compute_matches(game: String) raises -> Int:
    let winning = ints(split(split(game, ":")[1], "|")[0])
    let pulled = ints(split(split(game, ":")[1], "|")[1])
    
    var matches = 0
    for i in range(len(pulled)):
        for j in range(len(winning)):
            if winning[j] == pulled[i]:
                matches += 1
    
    return matches

fn part1() raises -> String:
    var total = 0

    for line in get_lines('inputs/day4.txt'):
        let matches = compute_matches(line)
        total += 0 if matches == 0 else (1 << (matches - 1))

    return total

fn recurse(
    inout lines: StringVector,
    inout memos: IntMap[Int],
    idx: Int
) raises -> Int:
    if idx >= len(lines):
        return 0 # out of bounds

    if memos.contains(idx):
        return memos[idx]

    let matches = compute_matches(lines[idx])
    var total = 1 # this card
    for offs in range(matches):
        total += recurse(lines, memos, idx + 1 + offs)
    
    memos[idx] = total
    return total

fn part2() raises -> String:
    var memos = IntMap[Int]()
    var lines = get_lines('inputs/day4.txt')
    var total = 0
    for i in range(len(lines)):
        total += recurse(lines, memos, i)
    return total

fn solve() raises -> String:
    return String(part1()) + ", " + String(part2()) # 19135, 5704953
