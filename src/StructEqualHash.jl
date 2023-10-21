module StructEqualHash

export @struct_equal_hash

Base.@assume_effects :foldable typeid(T::Type) = objectid(T)

typehash(::Type{T}, h::UInt) where T = hash(3*h-typeid(T))

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
