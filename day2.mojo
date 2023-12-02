from common.stringvector import StringVector
from common.hashmap import StringMap
from common.io import get_lines
from common.parsing import split, substr
from math import max

fn part1() raises -> String:    
    var counts = StringMap[Int]()
    counts["red"] = 12
    counts["green"] = 13
    counts["blue"] = 14

    var total = 0
    for line in get_lines('inputs/day2.txt'):
        var parts = split(line, ":")
        let gamenr = atol(substr(parts[0], len("Game ")))
        var all_valid = True
        for pull in split(parts[1], ";"):
            let groups = split(pull, ",")
            for group in groups:
                let stripped = substr(group, 1) # no leading space
                var count_color = split(stripped, " ")
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

        var parts = split(line, ":")
        let gamenr = atol(substr(parts[0], len("Game ")))

        for pull in split(parts[1], ";"):
            let groups = split(pull, ",")
            for group in groups:
                let stripped = substr(group, 1) # no leading space
                var count_color = split(stripped, " ")
                let new_max = max(max_seen[count_color[1]], atol(count_color[0]))
                max_seen[count_color[1]] = new_max

        let power = max_seen["red"] * max_seen["green"] * max_seen["blue"]
        total += power

    return String(total) # 71220