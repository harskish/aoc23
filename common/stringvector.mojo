from utils.vector import DynamicVector

# DynamicVector[String] does not provide __iter__, thus the class below
# Original implementation: github.com/gabrieldemarmiesse/mojo-stdlib-extensions
# This file is licensed under the MIT license (github.com/gabrieldemarmiesse/mojo-stdlib-extensions/blob/master/LICENSE)

alias StringVector = Vector[String]

@value
struct Vector[T: CollectionElement](Sized):
    var _raw: DynamicVector[T]

    fn __init__(inout self):
        self._raw = DynamicVector[T]()

    fn __init__(inout self, owned value: DynamicVector[T]):
        self._raw = value

    @always_inline
    fn _normalize_index(self, index: Int) -> Int:
        if index < 0:
            return len(self) + index
        else:
            return index

    fn __iter__(self) raises -> ListIterator[T]:
        return ListIterator[T](self._raw, len(self._raw))

    fn push_back(inout self, value: T):
        self._raw.push_back(value)

    fn clear(inout self):
        self._raw.clear()

    fn copy(self) -> Vector[T]:
        return Vector(self._raw)

    fn extend(inout self, other: Vector[T]):
        for i in range(len(other)):
            self.push_back(other.unchecked_get(i))

    fn pop(inout self, index: Int = -1) raises -> T:
        if index >= len(self._raw):
            raise Error("List index out of range")
        let new_index = self._normalize_index(index)
        let element = self.unchecked_get(new_index)
        for i in range(new_index, len(self) - 1):
            self[i] = self[i + 1]
        self._raw.resize(len(self._raw) - 1, element)
        return element

    fn reverse(inout self) raises:
        for i in range(len(self) // 2):
            let mirror_i = len(self) - 1 - i
            let tmp = self[i]
            self[i] = self[mirror_i]
            self[mirror_i] = tmp

    fn insert(inout self, key: Int, value: T) raises:
        let index = self._normalize_index(key)
        if index >= len(self):
            self.push_back(value)
            return
        # we increase the size of the array before insertion
        self.push_back(self[-1])
        for i in range(len(self) - 2, index, -1):
            self[i] = self[i - 1]
        self[key] = value

    fn __getitem__(self, index: Int) raises -> T:
        if index >= len(self._raw):
            raise Error("List index out of range")
        return self.unchecked_get(self._normalize_index(index))

    fn __getitem__(self: Self, limits: slice) raises -> Self:
        var new_list: Self = Self()
        for i in range(limits.start, limits.end, limits.step):
            new_list.push_back(self[i])
        return new_list

    @always_inline
    fn unchecked_get(self, index: Int) -> T:
        return self._raw[index]

    fn __setitem__(inout self, key: Int, value: T) raises:
        if key >= len(self._raw):
            raise Error("List index out of range")
        self.unchecked_set(self._normalize_index(key), value)

    @always_inline
    fn unchecked_set(inout self, key: Int, value: T):
        self._raw[key] = value

    @always_inline
    fn __len__(self) -> Int:
        return len(self._raw)

    @staticmethod
    fn from_string(input_value: String) -> Vector[String]:
        var result = Vector[String]()
        for i in range(len(input_value)):
            result.push_back(input_value[i])
        return result


fn list_to_str(input_list: Vector[String]) raises -> String:
    var result: String = "["
    for i in range(len(input_list)):
        let repr = "'" + str(input_list[i]) + "'"
        if i != len(input_list) - 1:
            result += repr + ", "
        else:
            result += repr
    return result + "]"

fn list_to_str(input_list: Vector[Int]) raises -> String:
    var result: String = "["
    for i in range(len(input_list)):
        let repr = str(input_list.__getitem__(index=i))
        if i != len(input_list) - 1:
            result += repr + ", "
        else:
            result += repr
    return result + "]"


struct ListIterator[T: CollectionElement]:
    var offset: Int
    var max_idx: Int
    var storage: Vector[T]
    
    fn __init__(inout self, storage: Vector[T], max_idx: Int):
        self.offset = 0
        self.max_idx = max_idx
        self.storage = storage
    
    fn __len__(self) -> Int:
        return self.max_idx - self.offset
    
    fn __next__(inout self) raises -> T:
        let ret: T = self.storage[self.offset]
        self.offset += 1
        return ret