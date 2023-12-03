import day1, day2, day3

fn check(val: String, target: String) raises:
    if val != target:
        raise Error("Expected " + target)

fn check_previous() raises:
    check(day1.solve(), "53386, 53312")
    check(day2.solve(), "2377, 71220")
    check(day3.solve(), "544433, 76314915")
    print("Passed")

fn main() raises:
    check_previous()