from sys.info import sizeof

# From: github.com/gabrieldemarmiesse/mojo-stdlib-extensions/tree/master
# License: MIT

trait Equalable:
    fn __eq__(self: Self, other: Self) -> Bool:
        ...

trait Hashable(Equalable):
    fn __hash__(self) -> Int:
        ...

fn hash[T: Hashable](x: T) -> Int:
    return x.__hash__()

fn hash(x: Int) -> Int:
    return x

fn hash(x: Int64) -> Int:
    """We assume 64 bits here, which is a big assumption.
    TODO: Make it work for 32 bits.
    """
    return hash(x.to_int())

fn hash(x: String) -> Int:
    """Very simple hash function."""
    let prime = 31
    var hash_value = 0
    for i in range(len(x)):
        hash_value = prime * hash_value + ord(x[i])
    return hash_value

trait HashableCollectionElement(CollectionElement, Hashable):
    pass


@register_passable
struct HashableInt(HashableCollectionElement):
    var a: Int
    fn __init__(one: Int) -> Self:
        return Self{a: one}
    fn __copyinit__(existing) -> Self:
        return Self{a: existing.a}
    fn __hash__(self) -> Int:
        return self.a
    fn __eq__(self: Self, other: Self) -> Bool:
        return self.a == other.a

struct HashableString(HashableCollectionElement):
    var a: String
    fn __init__(inout self, v: String):
        self.a = v
    fn __init__(inout self, v: StringLiteral):
        self.a = String(v)
    fn __moveinit__(inout self, owned other: Self):
        self.a = other.a
    fn __copyinit__(inout self, borrowed other: Self):
        self.a = String("")
        # TODO: figure out how to use memcpy instead
        for i in range(len(other.a)):
            self.a += other.a[i]
    fn __hash__(self) -> Int:
        return hash(self.a)
    fn __eq__(self: Self, other: Self) -> Bool:
        return self.a == other.a