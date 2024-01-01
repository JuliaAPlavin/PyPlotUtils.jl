module UnitfulExt
using Unitful: Quantity, ustrip, unit
using PyPlotUtils
import PyPlotUtils: extent_ax, _ustrip

extent_ax(a::AbstractRange{<:Quantity}) = extent_ax(ustrip.(a))

_ustrip(x::Quantity) = ustrip(x)

end
