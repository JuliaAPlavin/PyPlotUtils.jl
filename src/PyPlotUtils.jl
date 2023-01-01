module PyPlotUtils

using PyCall
import PyPlot
using PyPlot: plt, matplotlib
using IntervalSets
using DomainSets
using DomainSets: ×
using AxisKeys: KeyedArray, axiskeys, dimnames
using OffsetArrays: OffsetArray
using Unitful: Quantity, ustrip, unit
using StatsBase: mad
using Colors
using NonNegLeastSquares: nonneg_lsq
using DataPipes
using Accessors: @optic, set
using LinearAlgebra: tril


export
    plt, matplotlib,
    .., ±, ×,
    pyplot_style!,
    keep_plt_lims, set_xylims, xylims_set, lim_intersect, lim_union,
    xylabels, legend_inline_right,
    imshow_ax, SymLog, ColorBar,
    mpl_color, adjust_lightness,
    ScalebarArtist


include("legend.jl")
include("artists.jl")


get_plt() = pyimport("matplotlib.pyplot")
get_matplotlib() = pyimport("matplotlib")
gca() = get_plt().gca()

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

function keep_plt_lims(func, ax=gca(); x=true, y=true)
    xl = ax.get_xlim()
    yl = ax.get_ylim()
    res = func()
    x && ax.set_xlim(xl)
    y && ax.set_ylim(yl)
    return res
end

extract_xylims(L::Rectangle) = (@assert dimension(L) == 2; endpoints.(components(L)))
function xylims_set(L; inv=[], ax=gca())
    xl, yl = extract_xylims(L)
    ax.set_xlim(xl...)
    ax.set_ylim(yl...)
    for k in [inv;]
        getproperty(ax, Symbol(:invert_, k, :axis))()
    end
end
const set_xylims = xylims_set  # backwards compatibility

"    lim_intersect(; [x::Interval], [y::Interval])
Shrink plot limits to the intersection of current limits with passed intervals. "
function lim_intersect(; x=nothing, y=nothing)
    !isnothing(x) && plt.xlim(extrema(Interval(plt.xlim()...) ∩ x))
    !isnothing(y) && plt.ylim(extrema(Interval(plt.ylim()...) ∩ y))
end

"    lim_union(; [x::Interval], [y::Interval])
Expand plot limits to the union of current limits with passed intervals. "
function lim_union(; x=nothing, y=nothing)
    !isnothing(x) && plt.xlim(extrema(Interval(plt.xlim()...) ∩ x))
    !isnothing(y) && plt.ylim(extrema(Interval(plt.ylim()...) ∩ y))
end

function xylabels(A::AbstractMatrix; units=eltype(axiskeys(A, 1)) <: Quantity, kwargs...)
    ustrs = if units
        T = eltype.(axiskeys(A))
        " ($(unit(T[1])))", " ($(unit(T[2])))"
    else
        "", ""
    end
    if dimnames(A) == (:ra, :dec)
        xylabels("RA$(ustrs[1])", "Dec$(ustrs[2])"; kwargs...)
    else
        xylabels("$(dimnames(A, 1))$(ustrs[1])", "$(dimnames(A, 2))$(ustrs[2])"; kwargs...)
    end
end

function xylabels(xl, yl; inline=false, at=(0, 0), ax=gca())
    if inline
        m = match(r"^([^()]+)\s+(\([^()]+\))$", yl)
        if !isnothing(m)
            yl = "$(m[1])\n$(m[2])"
        end
        keep_plt_lims(ax) do
            ticks = ax.get_xticks()
            ax.set_xticks(ticks)
            ax.set_xticklabels([t == at[1] ? xl : t for t in ticks])
            ticks = ax.get_yticks()
            ax.set_yticks(ticks)
            ax.set_yticklabels([t == at[2] ? yl : t for t in ticks])
        end
    else
        ax.set_xlabel(xl)
        ax.set_ylabel(yl)
    end
end

PyCall.PyObject(c::Colorant) = PyObject(mpl_color(c))
mpl_color(c::Colorant) = mpl_color(convert(RGBA{Float64}, c))
mpl_color(c::RGBA{Float64}) = (red(c), green(c), blue(c), alpha(c))
mpl_color(c::Union{Symbol, String, PyObject}) = RGBA(matplotlib.colors.to_rgba(c)...)
mpl_color(T::Type{<:Colorant}, c::Union{Symbol, String, PyObject}) = convert(T, mpl_color(c))

function adjust_lightness(color, amount)
    c = get(pyimport("matplotlib.colors").cnames, color, color)
    c = pyimport("colorsys").rgb_to_hls(pyimport("matplotlib.colors").to_rgb(c)...)
    return pyimport("colorsys").hls_to_rgb(c[1], max(0, min(1, amount * c[2])), c[3])
end

extent_ax(a::AbstractRange) = (first(a) - step(a) / 2, last(a) + step(a) / 2)
extent_ax(a::AbstractRange{<:Quantity}) = extent_ax(ustrip.(a))
extent_arr(A::AbstractMatrix) = (extent_ax(axes(A, 1))..., extent_ax(axes(A, 2))...)  # regular arrays, OffsetArrays, (...?)
extent_arr(A::KeyedArray) = (extent_ax(axiskeys(A, 1))..., extent_ax(axiskeys(A, 2))...)


Base.@kwdef struct ColorBar
    unit = nothing
    title = nothing
    label = nothing
end

Base.@kwdef struct SymLog
    linthresh = nothing
    nσ = 15
    vmin = nothing
    vmax = nothing
end

get_mpl_norm(A, n::Nothing) = matplotlib.colors.Normalize(vmin=minimum(A), vmax=maximum(A))
get_mpl_norm(A, n::PyObject) = n
get_mpl_norm(A, n::SymLog) = let
    linthresh = @something(n.linthresh, mad(A, normalize=true) * n.nσ)
    norm = matplotlib.colors.SymLogNorm(
        linthresh,
        vmin=@something(n.vmin, minimum(A)),
        vmax=@something(n.vmax, maximum(A)),
        base=ℯ  # before mpl 3.4: default base is ℯ; mpl 3.4+: default base is 10
    )
end

function imshow_ax(A::AbstractMatrix, colorbar=nothing; ax=gca(), norm=nothing, cmap=nothing, background_val=0, kwargs...)
    norm = get_mpl_norm(A, norm)
    isnothing(background_val) || ax.set_facecolor(plt.get_cmap(cmap)(norm(background_val)))
    mappable = ax.imshow(
        parent(A) |> permutedims;
        origin=:lower, extent=extent_arr(A),
        norm, cmap,
        kwargs...
    )
    if !isnothing(colorbar)
        cbar_kws = hasproperty(norm, :linthresh) ? (
            ticks=matplotlib.ticker.SymmetricalLogLocator(; subs=[1, 2, 5], base=10, norm.linthresh),
            format=matplotlib.ticker.EngFormatter(unit=string(something(colorbar.unit, "")), places=0, sep=" "),
        ) : (
            format=matplotlib.ticker.EngFormatter(unit=string(something(colorbar.unit, "")), places=0, sep=" "),
        )
        cb = plt.colorbar(mappable; colorbar.label, pad=0.02, cbar_kws...)
        isnothing(colorbar.title) || cb.ax.set_title(colorbar.title)
    end
end

end
