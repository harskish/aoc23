from common.stringvector import StringVector
from common.hashmap import IntMap, StringMap
from common.hash import hash, HashableCollectionElement
from common.io import get_lines
from common.parsing import split
from math import max

fn part1() raises -> String:
    var counts = StringMap[Int]()
    counts["red"] = 12
    counts["green"] = 13
    counts["blue"] = 14

    var total = 0
    for line in get_lines('inputs/day2.txt'):
        let parts = split(line, ":")
        let gamenr = atol(parts[0][5:]) # drop "Game "
        var all_valid = True
        for pull in split(parts[1], ";"):
            let groups = split(pull, ",")
            for group in groups:
                let count_color = split(group[1:], " ")
                let is_valid = atol(count_color[0]) <= counts[count_color[1]]
                all_valid = all_valid and is_valid
        total += gamenr if all_valid else 0

    return String(total) # 2377

fn part2() raises -> String:
    var max_seen = StringMap[Int]()
    var total = 0
    for line in get_lines('inputs/day2.txt'):
        max_seen["red"] = 0
        max_seen["green"] = 0
        max_seen["blue"] = 0

        let parts = split(line, ":")
        for pull in split(parts[1], ";"):
            let groups = split(pull, ",")
            for group in groups:
                let count_color = split(group[1:], " ")
                let new_max = max(max_seen[count_color[1]], atol(count_color[0]))
                max_seen[count_color[1]] = new_max

        let power = max_seen["red"] * max_seen["green"] * max_seen["blue"]
        total += power

    return String(total) # 71220

fn solve() raises -> String:
    return String(part1()) + ", " + String(part2())