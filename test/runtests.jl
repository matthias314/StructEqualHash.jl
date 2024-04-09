using StructEqualHash, Test

struct T{P}
    x::Int
    y::P
end

@struct_equal_hash T
@struct_equal_hash T{Char} (:x,)
@struct_equal_hash T{P} where P <: Number (:y,)

# methods for T
@inferred T(1, "a") == T(1, "b")
@test T(1, "a") != T(1, "b")
@inferred hash(T(1, "a"))
@test hash(T(1, "a")) != hash(T(1, "b"))
@test T(1, [1, 2]) == T(1, [1.0, 2.0])
@test hash(T(1, [1, 2])) == hash(T(1, [1.0, 2.0]))

# methods for T{Char}
@inferred T(1, 'a') == T(1, 'b')
@test T(1, 'a') == T(1, 'b')
@inferred hash(T(1, 'a'))
@test hash(T(1, 'a')) == hash(T(1, 'b'))

# methods for T{P} where P <: Number
@inferred T(1, 1) == T(2, 1)
@test T(1, 1) == T(2, 1)
@inferred hash(T(1, 1))
@test hash(T(1, 1)) == hash(T(2, 1))
@inferred isequal(T(1, 0.0), T(1, -0.0))
@test !isequal(T(1, 0.0), T(1, -0.0))
@test hash(T(1, 0.0)) != hash(T(1, -0.0))
