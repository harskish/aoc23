alias strtype = Pointer[SIMD[DType.int8, 1]]

# Return 64-bit FNV-1a hash for key (NUL-terminated). See description:
# https://en.wikipedia.org/wiki/Fowler–Noll–Vo_hash_function
alias FNV_OFFSET = UInt64(14695981039346656037)
alias FNV_PRIME = UInt64(1099511628211)
fn fnv_hash(key: String) -> UInt64:
    var hashval: UInt64 = FNV_OFFSET
    for i in range(len(key)):
        let p = UInt64(ord(key[i]))
        hashval ^= p #(uint64_t)(unsigned char)(*p)
        hashval *= FNV_PRIME
    return hashval

struct StringMap[V: AnyType]:
    var keys: Pointer[strtype]
    var vals: Pointer[V]

    var taken_mask: Pointer[Bool]
    var num_buckets: Int
    var num_elems: Int

    fn __init__(inout self):
        self.num_elems = 0
        self.num_buckets = 32
        self.keys = Pointer[strtype].get_null()
        self.vals = Pointer[V].get_null()
        self.taken_mask = Pointer[Bool].get_null()
        self.alloc_buffers()

    fn alloc_buffers(inout self):
        # HashNode split into two arrays
        # Linear probing in case of collision
        self.keys = self.keys.alloc(self.num_buckets)
        self.vals = self.vals.alloc(self.num_buckets)
        self.taken_mask = self.taken_mask.alloc(self.num_buckets)
        for i in range(self.num_buckets):
           self.taken_mask.store(i, False)

    fn load_factor(inout self) -> Float32:
        return Float32(self.num_elems) / self.num_buckets
    
    fn index_of(inout self, key: String) -> Int:
        return fnv_hash(key).to_int() % self.num_buckets

    fn comp_key(inout self, key1: strtype, key2: String) -> Bool:
        let key1_string = String(key1)
        return key1_string == key2

    # Doubles the size of the storage
    fn grow(inout self):
        let keys_old = self.keys
        let vals_old = self.vals
        let mask_old = self.taken_mask
        let len_old = self.num_buckets

        self.num_elems = 0
        self.num_buckets *= 2
        self.alloc_buffers()

        # Rehash content
        # Load factor currently zero => no infinite recursion
        for i in range(len_old):
            if mask_old[i]:
                #print_no_newline("[Rehashing] ")
                self.__setitem__(String(keys_old[i]), vals_old[i])
            
        keys_old.free()
        vals_old.free()
        mask_old.free()

    fn __getitem__(inout self, key: String) raises -> V:
        let base_idx = self.index_of(key)
        for i in range(self.num_buckets):
            let idx = (base_idx + i) % self.num_buckets
            if self.taken_mask[idx] and self.comp_key(self.keys[idx], key):
                return self.vals[idx]
        raise Error("Key not found in dict")
    
    fn __setitem__(inout self, key: String, value: V):
        if self.load_factor() > 0.65:
            print("Growing to", 2*self.num_buckets)
            self.grow()

        var idx = self.index_of(key)
        #print("Adding", key, "at index", idx)

        var overwriting = False
        while self.taken_mask[idx]:
            if self.comp_key(self.keys[idx], key):
                overwriting = True
                break
            idx = (idx + 1) % self.num_buckets
        
        # Store a copy of the key string
        if not overwriting:
            let str_copy = strtype.alloc(len(key) + 1)
            memcpy(str_copy, key._buffer.data, len(key) + 1)
            self.keys.store(idx, str_copy)
            self.num_elems += 1

        self.vals.store(idx, value)
        self.taken_mask.store(idx, True)
