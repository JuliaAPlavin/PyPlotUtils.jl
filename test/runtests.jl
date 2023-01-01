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

xylabels_compact()

# imshow([1 2; 3 4])
# imshow(OffsetArray([1 2; 3 4], -5:-4, 0:1))
# imshow(KeyedArray([1 2; 3 4], a=-5:-4, b=0:1))
# imshow(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"))
# imshow(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"s"))

# imshow_symlog(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"))
# colorbar_symlog(linthresh=5)

import CompatHelperLocal as CHL
CHL.@check()
