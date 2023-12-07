from common.stringvector import StringVector
from common.hashmap import StringMap, IntMap
from common.io import get_contents, get_lines
from math import min, max

struct Field:
    var field: String
    var W: Int
    var H: Int
    
    def __init__(inout self, owned data: String):
        self.field = data
        let rows = data.split("\n")
        self.H = len(rows)
        self.W = len(rows[0])
    
    # Out of bounds reads replaced by `.`
    def char_at(inout self, col: Int, row: Int) -> String:
        if 0 <= col < self.W and 0 <= row < self.H:
            return self.field[row * (self.W+1) + col] # +1 for newline
        return String(".")

    fn get_1_ring(inout self, col: Int, row: Int) raises -> StringVector:
        var ret = StringVector(9)
        for dr in range(-1, 2):
            for dc in range(-1, 2):
                ret.push_back(self.char_at(col + dc, row + dr))
        return ret^

    # Ignores `.`
    fn nearby_symbols(inout self, col: Int, row: Int) raises -> StringVector:
        var symbols = StringVector()
        for c in self.get_1_ring(col, row):
            if not isdigit(c._buffer[0]) and c != ".":
                symbols.push_back(c)
        return symbols^

    # Assume only one
    fn nearby_gear(inout self, col: Int, row: Int) raises -> Int:
        for dr in range(-1, 2):
            for dc in range(-1, 2):
                let c = col + dc
                let r = row + dr
                if self.char_at(c, r) == "*":
                    return r * self.W + c # unique id
        return -1

fn solve() raises -> String:
    let strdata: String = get_contents('inputs/day3.txt')
    var field = Field(strdata)
    var total = 0
    
    # Coord to gear ratio
    var gear_ratios = IntMap[Int]()
    var num_comp = IntMap[Int]() # how many connected components

    # Read out of bounds (generates `.`)
    # This way EOL is implicitly handled
    for r in range(0, field.H + 1):
        var is_part_num = False
        var seen_gear = -1
        var curr_num: String = ""
        for c in range(0, field.W + 1):
            let curr = field.char_at(c, r)
            if isdigit(curr._buffer[0]):
                curr_num = curr_num + curr
                if not is_part_num:
                    is_part_num = len(field.nearby_symbols(c, r)) > 0
                if seen_gear == -1:
                    seen_gear = field.nearby_gear(c, r)
            else:
                # Symbol (or implicit line end)
                if is_part_num:
                    total += atol(curr_num)
                    if seen_gear != -1:
                        # DefaultDict would be nice...
                        if not gear_ratios.contains(seen_gear):
                            gear_ratios[seen_gear] = 1
                            num_comp[seen_gear] = 0
                        gear_ratios[seen_gear] = gear_ratios[seen_gear] * atol(curr_num)
                        num_comp[seen_gear] = num_comp[seen_gear] + 1
                
                # Reset
                seen_gear = -1
                is_part_num = False
                curr_num = ""

    var ratio_sum = 0
    for k in gear_ratios.get_keys():
        if num_comp[k] == 2:
            ratio_sum += gear_ratios[k]

    return String(total) + ", " + ratio_sum # 544433, 76314915