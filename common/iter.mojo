from utils.vector import DynamicVector

struct DynamicVecIterator[T: CollectionElement]:
    var offset: Int
    var max_idx: Int
    var storage: DynamicVector[T]
    
    fn __init__(inout self, storage: DynamicVector[T], max_idx: Int):
        self.offset = 0
        self.max_idx = max_idx
        self.storage = storage
    
    fn __len__(self) -> Int:
        return self.max_idx - self.offset
    
    fn __next__(inout self) raises -> T:
        let ret: T = self.storage[self.offset]
        self.offset += 1
        return ret

struct iter[T: CollectionElement]:
    var data: DynamicVector[T]
    
    def __init__(inout self, vec: DynamicVector[T]):
        self.data = vec
    
    fn __iter__(self) raises -> DynamicVecIterator[T]:
        return DynamicVecIterator[T](self.data, len(self.data))