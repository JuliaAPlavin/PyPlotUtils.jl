using PyPlotUtils
using AxisKeys
using OffsetArrays
using Unitful
using Colors
using Test


pyplot_style!()

keep_plt_lims() do
end

adjust_lightness(:C0, 0.5)
adjust_lightness(:C0, 1.5)

set_xylims((5 ± 1) × (1..5); inv=:x)

lim_intersect(x=5 ± 1)
lim_union(y=5 ± 1)

legend_inline_right()
plt.plot(1:10, label="abc")
legend_inline_right()
plt.plot(1:10, label="def")
plt.fill_between(1:10, 1:10, 1:10, label="xyz")
legend_inline_right()

xylabels("a", "b")
xylabels("a", "b"; inline=true)
xylabels(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"))
xylabels(KeyedArray([1 2; 3 4], ra=(-5:-4)u"m", dec=(0:1)u"m"))

@test mpl_color(:C1) ≈ RGBA(1, 0.5, 0.055, 1)  rtol=0.01
@test mpl_color("#0f0f0f80") ≈ RGBA(0.059, 0.059, 0.059, 0.5)  rtol=0.01
@test mpl_color(coloralpha(mpl_color(:C1), 0.2)) == (1.0, 0.4980392156862745, 0.054901960784313725, 0.2)

imshow_ax([1 2; 3 4])
imshow_ax(OffsetArray([1 2; 3 4], -5:-4, 0:1))
imshow_ax(KeyedArray([1 2; 3 4], a=-5:-4, b=0:1))
imshow_ax(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"))
imshow_ax(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"), ColorBar())
imshow_ax(KeyedArray([1 2; 3 4], a=(-5:-4)u"m", b=(0:1)u"m"), ColorBar(); norm=SymLog())

plt.gca().add_artist(ScalebarArtist([(1, "px")]))

axplotfunc(sin)
label_log_scales([:x])

let xys = map(t -> (1.5 - cos(t), sin(t)), 0:0.1:2π)
    draw_text_along((2, 1), "abc", xys; offset_pixels=5, color=:green)
end

add_zoom_patch(plt.gca(), plt.gca(), :horizontal)


import CompatHelperLocal as CHL
CHL.@check()
import Aqua
Aqua.test_all(PyPlotUtils; ambiguities=false, project_toml_formatting=false)
Aqua.test_ambiguities(PyPlotUtils; recursive=false)
