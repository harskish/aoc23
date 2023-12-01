from utils.vector import DynamicVector
from memory import memcpy
import math

# https://mzaks.medium.com/counting-chars-with-simd-in-mojo-140ee730bd4d

alias strtype = DTypePointer[DType.int8]

struct StringVector:
    var size: Int
    var capacity: Int
    var storage: Pointer[strtype]

    fn __init__(inout self):
        self.size = 0
        self.capacity = 32
        self.storage = Pointer[strtype].alloc(self.capacity)

    fn push_back(inout self, value: String):
        if self.size == self.capacity:
            self.grow()
        let data = strtype.alloc(len(value) + 1)
        memcpy(data, value._buffer.data, len(value) + 1) # including null terminator
        self.storage.store(self.size, data)
        self.size += 1
    
    fn grow(inout self):
        self.resize(2*self.capacity)

    fn extend[*Ts: AnyType](inout self, owned literal: ListLiteral[Ts]):
        # https://mojodojo.dev/guides/builtins/BuiltinList.html#fields
        # https://github.com/modularml/mojo/issues/655
        let src = Pointer.address_of(literal).bitcast[StringLiteral]()
        for i in range(len(literal)):
            let s = String(src.load(i))
            self.push_back(s)

    fn resize(inout self, newsize: Int):
        let storage_old = self.storage
        self.storage = Pointer[strtype].alloc(newsize)
        memcpy(self.storage, storage_old, math.min(newsize, self.capacity))
        
        # If shrinking: free overflow
        for i in range(newsize, self.capacity):
            #print('Freeing index', i)
            storage_old[i].free()

        storage_old.free()
        self.size = math.min(newsize, self.capacity)
        self.capacity = newsize
        #print('New capacity:', self.capacity)
        
    fn __getitem__(inout self, index: Int) -> String:
        let d: strtype = self.storage.load(index)
        return String(d)

    fn __setitem__(inout self, i: Int, value: String):
        self.storage.load(i).free()
        let data = strtype.alloc(len(value))
        memcpy(data, value._buffer.data, len(value))
        self.storage.store(i, data)

    fn __iter__(self) -> StringListIterator:
        return StringListIterator(self.storage, self.size)
    
    fn __moveinit__(inout self, owned previous: Self):
        self.size = previous.size
        self.capacity = previous.capacity
        self.storage = previous.storage

    fn len(inout self) -> Int:
        return self.size
    
    fn clear(inout self):
        self.size = 0
        self.resize(0)
    
    # fn reverse(inout self):
    #     var left: Int = 0
    #     var right: Int = self.size - 1
    #     let temp: T
    #     while left <= right:
    #         temp = self.storage.load(left)
    #         self.storage.store(left, self.storage.load(right))
    #         self.storage.store(right, temp)
    #         left += 1
    #         right -= 1

    # fn remove(inout self, index: Int):
    #     for i in range(index, self.size):
    #         self.storage.store(i, self.storage.load(i+1))
    #     self.size -= 1

    # fn pop(inout self, index: Int) -> T:
    #     let data = self.storage.load(index)
    #     self.remove(index)
    #     return data

    # fn swap(inout self, index1: Int, index2: Int):
    #     let temp: T
    #     temp = self.storage.load(index1)
    #     self.storage.store(index1, self.storage.load(index2))
    #     self.storage.store(index2, temp)

    # fn insert(inout self, index: Int, value: T):
    #     if self.size == self.capacity:
    #         self.resize(self.capacity * 2)
    #     for i in range(self.size, index, -1):
    #         self.storage.store(i, self.storage.load(i-1))
    #     self.storage.store(index, value)
    #     self.size += 1

    # fn copy(self) -> Self:
    #     var new = Self(self.size)
    #     for item in self: new.push_back(item)
    #     return new^

struct StringListIterator:
    var offset: Int
    var max_idx: Int
    var storage: Pointer[strtype]
    
    fn __init__(inout self, storage: Pointer[strtype], max_idx: Int):
        self.offset = 0
        self.max_idx = max_idx
        self.storage = storage
    
    fn __len__(self) -> Int:
        return self.max_idx - self.offset
    
    fn __next__(inout self) -> String:
        let ret = self.storage.load(self.offset)
        self.offset += 1
        return String(ret)