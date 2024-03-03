# StructEqualHash.jl

This is a Julia package to define equality and hash for structs.
It is similar to [AutoHashEquals.jl](https://github.com/JuliaServices/AutoHashEquals.jl),
[StructEquality.jl](https://github.com/jolin-io/StructEquality.jl) and
[StructHelpers.jl](https://github.com/jw3126/StructHelpers.jl).
It aims to be lightweight and does not use `@generated` code.

## Usage

The macro call
```julia
@struct_equal_hash T [fields]
```
generates definitions for `==`, `isequal` and `hash` for the struct `T`,
```julia
    function x::T == y::T
    function isequal(x::T, y::T)
    function hash(x::T, h0::UInt)
```

The equality tests are applied, using short-circuit logic, to the fields of `T`
specified by the tuple `fields`. The default for `fields` is all fields of `T`
in the order in which they have been declared. The hash is similarly computed
over the type name `T` as well as over the fields given by `fields`.
Empty structs are allowed.

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

## Examples
```julia
julia> struct T{P}; x::Int; y::P end

julia> @struct_equal_hash T

julia> @struct_equal_hash T{Char} (:x,)

julia> @struct_equal_hash T{P} where P <: Number (:y,)

julia> T(1, "a") == T(1, "b")   # method for T
false

julia> T(1, [1, 2]) == T(1, [1.0, 2.0])   # method for T
true

julia> T(1, 'a') == T(1, 'b')   # method for T{Char}
true

julia> T(1, 1) == T(2, 1)       # method for T{P} where P <: Number
true
```
