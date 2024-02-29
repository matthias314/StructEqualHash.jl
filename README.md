# StructEqualHash.jl

This is a Julia package to define equality and hash for structs.
It is similar to [AutoHashEquals.jl](https://github.com/JuliaServices/AutoHashEquals.jl)
and [StructEquality.jl](https://github.com/jolin-io/StructEquality.jl).
It aims to be lightweight and does not use `@generated` code.

## Usage

The macro call
```julia
@struct_equal_hash T
```
generates definitions for `==`, `isequal` and `hash` for the struct `T`,
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
