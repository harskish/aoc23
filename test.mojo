import day1, day2

fn check(val: String, target: String) raises:
    if val != target:
        raise Error("Expected " + target)

fn check_previous() raises:
    check(day1.part1(), "53386")
    check(day1.part2(), "53312")
    check(day2.part1(), "2377")
    check(day2.part2(), "71220")
    print("Passed")

fn main() raises:
    check_previous()