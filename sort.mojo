from builtin.builtin_list import ListLiteral
from memory.unsafe import Pointer
from builtin.io import _Printable

# Casting stuff: https://mojodojo.dev/guides/benchmarks/sudoku.html

struct List[T: AnyType]:
    var ptr: Pointer[T]
    var count: Int
    var capacity: Int
    
    fn __init__[*Ts: AnyType](inout self, owned literal: ListLiteral[Ts]):
        self.count = len(literal)
        self.capacity = self.count
        self.ptr = Pointer[T].alloc(self.count)

        # https://mojodojo.dev/guides/builtins/BuiltinList.html#fields
        # https://github.com/modularml/mojo/issues/655
        let src = Pointer.address_of(literal).bitcast[T]()
        for i in range(self.count):
            self.ptr.store(i, src.load(i))
              
    fn __getitem__(self, i: Int) -> T:
        return self.ptr.load(i)
    
    fn __setitem__(inout self, i: Int, value: T):
        self.ptr.store(i, value)
    
    fn __len__(self) -> Int:
        return self.count

fn print_arr(arr: List[Int], eol: String = "\n"):
    for i in range(arr.count):
        print_no_newline(arr[i], " ")
    print_no_newline(eol)

fn sort(inout arr: List[Int]):
    for i in range(arr.count):
        for j in range(i, arr.count):
            if arr[j] < arr[i]:
                let tmp = arr[i]
                arr[i] = arr[j]
                arr[j] = tmp

def main():
    var arr = List[Int]([5, 3, 5, 1, 2, 7, 6, 9, 7, 4, 3, 2])
    print_arr(arr)
    sort(arr)
    print_arr(arr)
    print("Done")

# what?