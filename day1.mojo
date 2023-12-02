from common.stringvector import StringVector
from common.io import get_lines
from common.parsing import digits, reverse, first_substr_match

fn part1() raises -> String:    
    let lines = get_lines('inputs/day1.txt')
    
    var total = 0
    for s in lines:
        let dgts: DynamicVector[Int] = digits(s)
        let first = dgts[0]
        let last = dgts[len(dgts)-1]
        let value = first * 10 + last
        total += value

    return String(total) #53386

fn part2() raises -> String:
    var pattern_fwd = StringVector([
        "0", "1", "2", "3", "4",
        "5", "6", "7", "8", "9",
        "zero", "one", "two", "three", "four",
        "five", "six", "seven", "eight", "nine",
    ])

    # Reverse strings
    var pattern_rev = StringVector()
    for s in pattern_fwd:
       pattern_rev.push_back(reverse(s))

    var total = 0
    for line in get_lines('inputs/day1.txt'):
        # Scan forward
        let idx_first: Int = first_substr_match(line, pattern_fwd).get[1, Int]()
        let val_first = idx_first % 10
        total += val_first * 10 # 10s place
        
        # Scan reverse
        let line_rev = reverse(line)
        let idx_last: Int = first_substr_match(line_rev, pattern_rev).get[1, Int]()
        let val_last = idx_last % 10
        total += val_last # 1s place

    return String(total) # 53312