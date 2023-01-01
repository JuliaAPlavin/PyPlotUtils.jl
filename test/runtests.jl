using PyPlotUtils
using PyPlot
using AxisKeys
using OffsetArrays
using Unitful

pyplot_style!()

keep_plt_lims() do
end

adjust_lightness(:C0, 0.5)
adjust_lightness(:C0, 1.5)

set_xylims((5 ± 1)^2)

xylabels("a", "b")
xylabels("a", "b"; inline=true)
xylabels(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"))

mpl_color(:C1)

imshow_ax([1 2; 3 4])
imshow_ax(OffsetArray([1 2; 3 4], -5:-4, 0:1))
imshow_ax(KeyedArray([1 2; 3 4], a=-5:-4, b=0:1))
imshow_ax(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"))
imshow_ax(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"), ColorBar())
imshow_ax(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"), ColorBar(); norm=SymLog())

import CompatHelperLocal as CHL
CHL.@check()
