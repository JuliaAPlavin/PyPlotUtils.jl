module UnitfulExt
using Unitful: Quantity, ustrip, unit
using PyPlotUtils
import PyPlotUtils: extent_ax

extent_ax(a::AbstractRange{<:Quantity}) = extent_ax(ustrip.(a))

end
