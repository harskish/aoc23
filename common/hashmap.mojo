# From: github.com/gabrieldemarmiesse/mojo-stdlib-extensions/tree/master
# License: MIT

from memory import memset_zero, memcpy
from .hash import hash, HashableCollectionElement, HashableInt, HashableString
from .stringvector import Vector

alias IntMap = HashMap[HashableInt]
alias StringMap = HashMap[HashableString]

struct HashMap[K: HashableCollectionElement, V: CollectionElement](Sized):
    var keys: Vector[K]
    var values: Vector[V]
    var key_map: Vector[Int]
    var deleted_mask: DTypePointer[DType.bool]
    var count: Int
    var capacity: Int

    fn __init__(inout self):
        self.count = 0
        self.capacity = 16
        self.keys = Vector[K]()
        self.values = Vector[V]()
        self.key_map = Vector[Int]()
        for i in range(self.capacity):
            self.key_map.push_back(0)
        self.deleted_mask = DTypePointer[DType.bool].alloc(self.capacity)
        memset_zero(self.deleted_mask, self.capacity)

    fn __setitem__(inout self, key: K, value: V):
        if self.count / self.capacity >= 0.8:
            self._rehash()

        self._put(key, value, -1)

    fn _make_deleted_mask_bigger(inout self, old_size: Int, new_size: Int):
        let _deleted_mask = DTypePointer[DType.bool].alloc(new_size)
        memset_zero(_deleted_mask, new_size)
        memcpy(_deleted_mask, self.deleted_mask, old_size)
        self.deleted_mask.free()
        self.deleted_mask = _deleted_mask

    fn _rehash(inout self):
        let old_mask_capacity = self.capacity
        self.capacity *= 2
        self.key_map = Vector[Int]()
        for i in range(self.capacity):
            self.key_map.push_back(0)

        self._make_deleted_mask_bigger(old_mask_capacity, self.capacity)

        for i in range(len(self.keys)):
            self._put(self.keys.unchecked_get(i), self.values.unchecked_get(i), i + 1)

    fn _put(inout self, key: K, value: V, rehash_index: Int):
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        var key_map_index = key_hash % modulo_mask
        while True:
            let key_index = int(self.key_map.unchecked_get(index=key_map_index))
            if key_index == 0:
                let new_key_index: Int
                if rehash_index == -1:
                    self.keys.push_back(key)
                    self.values.push_back(value)
                    self.count += 1
                    new_key_index = len(self.keys)
                else:
                    new_key_index = rehash_index
                self.key_map.unchecked_set(key_map_index, new_key_index)
                return

            let other_key = self.keys.unchecked_get(key_index - 1)
            if other_key == key:
                self.values.unchecked_set(key_index - 1, value)
                if self.deleted_mask[key_index - 1]:
                    self.count += 1
                    self.deleted_mask[key_index - 1] = False
                return

            key_map_index = (key_map_index + 1) % modulo_mask

    fn __getitem__(self, key: K) raises -> V:
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        var key_map_index = key_hash % modulo_mask
        while True:
            let key_index = self.key_map.__getitem__(index=key_map_index)
            if key_index == 0:
                raise Error("Key not found")
            let other_key = self.keys.unchecked_get(key_index - 1)
            if other_key == key:
                if self.deleted_mask[key_index - 1]:
                    raise Error("Key not found")
                return self.values[key_index - 1]
            key_map_index = (key_map_index + 1) % modulo_mask

    fn get(self, key: K, default: V) -> V:
        try:
            return self[key]
        except Error:
            return default

    fn contains(self, key: K) -> Bool:
        try:
            let dummy = self[key]
            return True
        except Error:
            return False

    fn get_keys(self) -> Vector[K]:
        return self.keys

    fn pop(inout self, key: K) raises:
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        var key_map_index = key_hash % modulo_mask
        while True:
            let key_index = self.key_map.__getitem__(index=key_map_index)
            if key_index == 0:
                raise Error("KeyError, key not found.")
            let other_key = self.keys.unchecked_get(key_index - 1)
            if other_key == key:
                self.count -= 1
                self.deleted_mask[key_index - 1] = True
                return
            key_map_index = (key_map_index + 1) % modulo_mask

    fn __len__(self) -> Int:
        return self.count
