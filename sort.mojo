from builtin.builtin_list import ListLiteral
from memory.unsafe import Pointer
from builtin.io import _Printable
from python import Python
from utils.index import Index
from random import rand
from common.io import get_lines
from common.stringvector import StringVector

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

fn from_np[type: DType](a: PythonObject) raises -> Tensor[type]:
    let w = a.shape[0].to_float64().to_int()
    let h = a.shape[1].to_float64().to_int()
    var out = Tensor[type](w, h)
    for i in range(w):
        for j in range(h):
            out[Index(i, j)] = a[i][j].to_float64().cast[type]()
    return out

fn list_sort_test():
    var arr = List[Int]([5, 3, 5, 1, 2, 7, 6, 9, 7, 4, 3, 2])
    print_arr(arr)
    sort(arr)
    print_arr(arr)

fn tensor_from_np_test() raises:
    let np = Python.import_module("numpy")
    let t = from_np[DType.float32](np.random.randn(2, 2))
    print(t)

fn main() raises:
    #let s = PythonObject("HELLO").lower().to_string()
    #print(s)
    #print(rand[DType.float32](1, 2, 3))
    
    #list_sort_test()
    #tensor_from_np_test()
    #let lines = get_lines('input.txt')

    var v = StringVector()
    v.push_back("Hello")
    v.push_back("World")
    v.push_back(",")
    v.push_back("how")
    v.push_back("is")
    v.push_back("it")
    v.push_back("going?")

    v[0] = "Goodbye"
    v.resize(1)

    for s in v:
        print(s)

    print("Done")

# what?