module PyPlotUtils

using PyCall
import PyPlot
using PyPlot: plt, matplotlib
using IntervalSets
using DomainSets
using AxisKeys: KeyedArray, axiskeys
using OffsetArrays: OffsetArray
using Unitful: ustrip
using StatsBase: mad

export
    plt, matplotlib,
    .., ±, ×,
    pyplot_style!, keep_plt_lims, set_xylims, xylabels_inline,
    adjust_lightness, colorbar_symlog, imshow_symlog

get_plt() = pyimport("matplotlib.pyplot")
get_matplotlib() = pyimport("matplotlib")

function pyplot_style!()
    seaborn = pyimport_conda("seaborn", "seaborn")
    seaborn.set_style("whitegrid", Dict("image.cmap" => "turbo"))
    seaborn.set_color_codes()
    plt = get_plt()
    plt.rc("grid", alpha=0.4)
    plt.rc("savefig", bbox="tight", pad_inches=0)
    rcParams = PyDict(get_matplotlib()."rcParams")
    for p in ["text.color", "axes.labelcolor", "xtick.color", "ytick.color"]
        rcParams[p] = "black"
    end
end

function keep_plt_lims(func, ax=nothing; x=true, y=true)
    ax = something(ax, get_plt().gca())
    xl = ax.get_xlim()
    yl = ax.get_ylim()
    res = func()
    x && ax.set_xlim(xl)
    y && ax.set_ylim(yl)
    return res
end

extract_xylims(L::Rectangle) = (@assert dimension(L) == 2; endpoints.(components(L)))
function set_xylims(L; inv=[])
    xl, yl = extract_xylims(L)
    ax = get_plt().gca()
    ax.set_xlim(xl...)
    ax.set_ylim(yl...)
    for k in [inv;]
        getproperty(ax, Symbol(:invert_, k, :axis))()
    end
end

function xylabels_inline(; x="RA (mas)", y="DEC (mas)", at=(0, 0))
    keep_plt_lims() do
        plt = get_plt()
        ticks = plt.xticks()
        plt.xticks(ticks[1], [t == at[1] ? x : t for t in ticks[1]])
        ticks = plt.yticks()
        plt.yticks(ticks[1], [t == at[2] ? y : t for t in ticks[1]])
    end
end

function adjust_lightness(color, amount)
    c = get(pyimport("matplotlib.colors").cnames, color, color)
    c = pyimport("colorsys").rgb_to_hls(pyimport("matplotlib.colors").to_rgb(c)...)
    return pyimport("colorsys").hls_to_rgb(c[1], max(0, min(1, amount * c[2])), c[3])
end

function colorbar_symlog(; linthresh, label=nothing, title=nothing)
    plt = get_plt()
    mpl = get_matplotlib()
    cb = plt.colorbar(;
        ticks=mpl.ticker.SymmetricalLogLocator(; subs=[1, 2, 5], base=10, linthresh),
        format=mpl.ticker.FuncFormatter((x, ix) -> (ix == 1 || ix % 10 == 0) ? string(round(x, sigdigits=1)) : ""),
#         format=mpl.ticker.FuncFormatter((x, ix) -> ix == 1 || ix % 10 == 0 ? (x == 0 ? "0" : abs(x) < 1 ? replace(f"{x * 1e3} m", ".0 " => " ") : f"{x:d}") : ""),
        label,
    )
    isnothing(title) || cb.ax.set_title(title)
    return cb
end

function imshow_symlog(img::KeyedArray; colorbar=true, linthresh=nothing, lims=nothing, nsigma=10, cmap=nothing, vmin=nothing, vmax=nothing, inv_x=true)
    plt = get_plt()
    mpl = get_matplotlib()
    plt.gca().set_aspect(:equal)
    plt.gca().set_facecolor(plt.get_cmap(cmap)(0))
    linthresh = linthresh == nothing ? mad(img, normalize=true) * nsigma : linthresh
    norm = mpl.colors.SymLogNorm(
        linthresh,
        vmin=something(vmin, minimum(img)), vmax=something(vmax, maximum(img)),
        base=ℯ)  # consistent with mpl before 3.4; in 3.4 default base becomes 10
    im = PyPlot.imshow(img; norm, cmap)
    if colorbar
        colorbar_symlog(; linthresh)
    end
    set_xylims(lims; inv_x)
    return im
end

function PyPlot.imshow(A::OffsetArray; kwargs...)
    PyPlot.imshow(
        parent(A) |> permutedims, origin=:lower,
        extent=(
            Base.axes(A, 1) |> first,
            Base.axes(A, 1) |> last,
            Base.axes(A, 2) |> first,
            Base.axes(A, 2) |> last,
        );
        kwargs...
    )
end

function PyPlot.imshow(A::KeyedArray; kwargs...)
    PyPlot.imshow(
        parent(A) |> permutedims, origin=:lower,
        extent=(
            axiskeys(A, 1) |> first,
            axiskeys(A, 1) |> last,
            axiskeys(A, 2) |> first,
            axiskeys(A, 2) |> last) .|> ustrip;
        kwargs...
    )
end

end
