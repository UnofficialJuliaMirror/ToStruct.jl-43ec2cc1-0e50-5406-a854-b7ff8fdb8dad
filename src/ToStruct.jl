module ToStruct

function tostruct(x::AbstractDict, T::DataType)
    # In order to convert to struct, x's keys must be able to be converted to symbol.
    x = Dict(Symbol(k) => v for (k, v) in x)

    args = map(fieldnames(T)) do fname
        FT = fieldtype(T, fname)
        v = get(x, fname, nothing)
        tostruct(v, FT)
    end
    T(args...)
end

function tostruct(x::AbstractDict, T::Type{U} where U<:AbstractDict)
    KT, VT = eltype(T()).types
    T(tostruct(k, KT) => tostruct(v, VT) for (k, v) in x)
end

function tostruct(x::AbstractArray, T::Type{U} where U<:AbstractArray)
    ET = eltype(T)
    T(collect(tostruct(e, ET) for e in x))
end

function tostruct(x::Any, T::Union)
    try
        tostruct(x, T.a)
    catch
        tostruct(x, T.b)
    end
end

function tostruct(x::Any, T::Type)
    try
        x::T
    catch
        T(x)
    end
end

end # module