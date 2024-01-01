module AxisKeysUnitfulExt
using Unitful: Quantity, unit
using AxisKeys: KeyedArray, axiskeys, dimnames
using PyPlotUtils
import PyPlotUtils: set_xylabels

function set_xylabels(A::KeyedArray; units=eltype(axiskeys(A, 1)) <: Quantity, kwargs...)
    ustrs = if units
        T = eltype.(axiskeys(A))
        " ($(unit(T[1])))", " ($(unit(T[2])))"
    else
        "", ""
    end
    set_xylabels("$(dimnames(A, 1))$(ustrs[1])", "$(dimnames(A, 2))$(ustrs[2])"; kwargs...)
end

end
