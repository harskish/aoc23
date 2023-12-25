from collections.vector import DynamicVector
from math import min, max, ceildiv
from math.limit import max_finite
from builtin.range import _ZeroStartingRange

struct DynamicVecIterator[T: CollectionElement]:
    var offset: Int
    var step: Int
    var max_idx: Int
    var storage: DynamicVector[T]
    
    fn __init__(inout self, storage: DynamicVector[T], slc: slice):
        self.offset = slc.start
        self.max_idx = min(len(storage), slc.end) if slc.end > 0 else max(0, len(storage) + slc.end)
        self.storage = storage
        self.step = 1 if slc.step == 0 else slc.step
        if slc.step < 0 and slc.start == 0:
            self.offset = len(storage) - 1
        if slc.step < 0 and SIMD[DType.int64, 1](slc.end) == max_finite[DType.int64]():
            self.max_idx = -1
        #print("offset:", self.offset, "max_idx:", self.max_idx, "step:", self.step)
    
    fn __len__(self) -> Int:
        return ceildiv(self.max_idx - self.offset, self.step)
    
    fn __next__(inout self) raises -> T:
        let ret: T = self.storage[self.offset]
        self.offset += self.step
        return ret

struct iter[T: CollectionElement]:
    var data: DynamicVector[T]
    var slc: slice
    
    fn __init__(inout self, vec: DynamicVector[T]):
        self.data = vec
        self.slc = slice(0, len(self.data))

    fn __init__(inout self, vec: DynamicVector[T], slc: slice):
        self.data = vec
        self.slc = slc
    
    fn __iter__(self) raises -> DynamicVecIterator[T]:
        return DynamicVecIterator[T](self.data, self.slc)

    fn __getitem__(self, slc: slice) -> iter[T]:
        return iter(self.data, slc)

    fn __setitem__(inout self, slc: slice, value: T):
        print("Not supported")
        return

fn test(it: iter[Int], target: String) raises -> None:
    var digits: String = ""
    for val in it:
        digits += String(val) + ", "
    digits = digits[:-2] if digits else "" # drop last comma
    let full = String("[") + digits + String("]")
    if full != target:
        raise Error(full + " != " + target)
    print_no_newline('.')

fn list(ran: _ZeroStartingRange) -> iter[Int]:
    var data = DynamicVector[Int]()
    for i in ran:
        data.append(i)
    return iter(data)

fn test_slice() raises -> None:
    test(list(range(5)), "[0, 1, 2, 3, 4]")
    test(list(range(5))[::1], "[0, 1, 2, 3, 4]")
    test(list(range(5))[::-1], "[4, 3, 2, 1, 0]")
    test(list(range(5))[::-3], "[4, 1]")
    test(list(range(10))[:-1:-4], "[]")
    test(list(range(10))[::2], "[0, 2, 4, 6, 8]")
    test(list(range(10))[3:5:9], "[3]")
    print("passed!")
    
fn main() raises:
    test_slice()