module StructEqualHash

export @struct_equal_hash

Base.@assume_effects :foldable typeid(T::Type) = objectid(T)

typehash(::Type{T}, h::UInt = UInt(0)) where T = hash(3*h-typeid(T))

totuple(x::T) where T = ntuple(i -> getfield(x, i), fieldcount(T))

iswhere(ex) = Meta.isexpr(ex, :where)

peel(ex) = iswhere(ex) ? peel(ex.args[1]) : ex

function wrap(ex, ex2)
    if iswhere(ex)
        Expr(ex.head, wrap(ex.args[1], ex2), map(esc, ex.args[2:end])...)
    else
        ex2
    end
end

"""
    @struct_equal_hash T

Generate definitions for `==`, `isequal` and `hash` for the struct `T`,
```julia
    function x::T == y::T
    function isequal(x::T, y::T)
    function hash(x::T, h0::UInt)
```

The equality tests are applied, using short-circuit logic, to all fields of `T`
in the order in which they have been declared. The hash is similarly computed
over the type name `T` as well as over all fields. Empty structs are allowed.

The type can be a `UnionAll` type like `T{P} where P`. In this case the
definitions are
```julia
    function x::T{P} == y::T{P} where P
    function isequal(x::T{P}, y::T{P}) where P
    function hash(x::T{P}, h0::UInt) where P
```
Here the methods for `==` and `isequal` only apply if `x` and `y` are of the same type `T{P}`
(for the same `P`). If you do not want this for a parametric type `T`, you can simply use the
form without parameters.

If `T` has two parameters, then
```julia
    @struct_equal_hash T{P,Q} where {P,Q}
```
defines methods where the types `P` and `Q` must agree for the two arguments of `==` and `isequal`.
If you only want the first types to agree, you can say
```julia
    @struct_equal_hash T{P,Q where Q} where P
```
or, equivalently,
```julia
    @struct_equal_hash T{P} where P
```
If you only want the second types to agree, you can say
```julia
    @struct_equal_hash T{P where P,Q} where Q
```
If both types may differ, you can say
```julia
    @struct_equal_hash T{P where P,Q where Q}
```
or again omit the parameters.
"""
macro struct_equal_hash(TW)
    T = esc(peel(TW))
    ex1 = wrap(TW, :(Base.:(==)(x::$T, y::$T)))
    ex2 = wrap(TW, :(Base.isequal(x::$T, y::$T)))    
    ex3 = wrap(TW, :(Base.hash(x::$T, h::UInt)))
    quote
        $ex1 = totuple(x) == totuple(y)
        $ex2 = isequal(totuple(x), totuple(y))
        $ex3 = hash(totuple(x), typehash($T, h))
    end
end

end
