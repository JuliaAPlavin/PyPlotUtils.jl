module PyPlotUtils

using PyCall
using PyPlot: plt, matplotlib
using IntervalSets
using DomainSets
using DomainSets: ×
using Statistics: mean
using StatsBase: mad
using ColorTypes
using NonNegLeastSquares: nonneg_lsq
using DirectionalStatistics: Circular
using DataPipes: @p
using FlexiMaps: filtermap
using Accessors
using LinearAlgebra: tril


export
    plt, matplotlib,
    .., ±, ×,
    pyplot_style!,
    keep_plt_lims, set_xylims, lim_intersect, lim_union,
    set_xylabels, xylabels, label_log_scales, draw_text_along, legend_inline_right,
    imshow_ax, SymLog, ColorBar,
    pcolormesh_ax, plot_ax, fill_between_ax,
    mpl_color, adjust_lightness,
    axplotfunc, add_zoom_patch,
    ScalebarArtist


include("legend.jl")
include("artists.jl")


"""    pyplot_style!()
Set up matplotlib to follow my preferred (opinionated!) style. """
function pyplot_style!()
    seaborn = pyimport_conda("seaborn", "seaborn")
    seaborn.set_style("whitegrid", Dict("image.cmap" => "turbo"))
    seaborn.set_color_codes()
    plt.rc("grid", alpha=0.4)
    plt.rc("savefig", bbox="tight", pad_inches=0)
    plt.rc("axes", edgecolor="0.5")
    plt.rc("legend", edgecolor="0.5")
    rcParams = PyDict(matplotlib."rcParams")
    for p in ["text.color", "axes.labelcolor", "xtick.color", "ytick.color"]
        rcParams[p] = "black"
    end
end

"""    keep_plt_lims(func, ax=plt.gca(); x=true, y=true)
Call `func()` and undo any changes to axis limits it made. """
function keep_plt_lims(func, ax=plt.gca(); x=true, y=true)
    xl = ax.get_xlim()
    yl = ax.get_ylim()
    res = func()
    x && ax.set_xlim(xl)
    y && ax.set_ylim(yl)
    return res
end

extract_xylims(L::Rectangle) = (@assert dimension(L) == 2; endpoints.(components(L)))

"""    set_xylims(L::Rectangle; [inv::Symbols], ax=plt.gca())

Set plot limits to the `L` rectangle: e.g. `set_xylims((0 ± 1)^2)`.

Inverts axes specified in `inv`: e.g. `inv=:x`.
"""
function set_xylims(L; inv=[], ax=plt.gca())
    xl, yl = extract_xylims(L)
    ax.set_xlim(xl...)
    ax.set_ylim(yl...)
    for k in [inv;]
        getproperty(ax, Symbol(:invert_, k, :axis))()
    end
end

"    lim_intersect(; [x::Interval], [y::Interval])
Shrink plot limits to the intersection of current limits with passed intervals. "
function lim_intersect(; x=nothing, y=nothing)
    # XXX: should keep inverted axis
    !isnothing(x) && plt.xlim(extrema(Interval(extrema(plt.xlim())...) ∩ x))
    !isnothing(y) && plt.ylim(extrema(Interval(extrema(plt.ylim())...) ∩ y))
end

"    lim_union(; [x::Interval], [y::Interval])
Expand plot limits to the union of current limits with passed intervals. "
function lim_union(; x=nothing, y=nothing)
    # XXX: should keep inverted axis
    !isnothing(x) && plt.xlim(extrema(Interval(extrema(plt.xlim())...) ∩ x))
    !isnothing(y) && plt.ylim(extrema(Interval(extrema(plt.ylim())...) ∩ y))
end

"""    set_xylabels(matrix; [units::Bool], [...])
Set the `x` and `y` plot labels to `dimnames` of the `matrix`. Assumes that the `matrix` is plotted with `imshow_ax`. """
function set_xylabels end

"""    set_xylabels(xl, yl; inline=false, at=(0, 0), ax=plt.gca())

Set the `x` and `y` labels at once, with extra features.

`inline`: put the label instead of a tick label. Replaces ticks at `x=at[1]` and `y=at[2]`.
"""
function set_xylabels(xl, yl; inline=false, at=(0, 0), ax=plt.gca())
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
const xylabels = set_xylabels  # backwards compatibility

PyCall.PyObject(c::Colorant) = PyObject(mpl_color(c))
mpl_color(c::Colorant) = mpl_color(convert(RGBA{Float64}, c))
mpl_color(c::RGBA{Float64}) = (red(c), green(c), blue(c), alpha(c))
mpl_color(c::Union{Symbol, String, PyObject, AbstractVector, Tuple{Vararg{Real}}}) = RGBA(matplotlib.colors.to_rgba(c)...)
mpl_color(T::Type{<:Colorant}, c::Union{Symbol, String, PyObject, AbstractVector, Tuple{Vararg{Real}}}) = convert(T, mpl_color(c))

function adjust_lightness(color, amount)
    c = get(pyimport("matplotlib.colors").cnames, color, color)
    c = pyimport("colorsys").rgb_to_hls(pyimport("matplotlib.colors").to_rgb(c)...)
    return pyimport("colorsys").hls_to_rgb(c[1], max(0, min(1, amount * c[2])), c[3])
end

extent_ax(a::AbstractRange) = (first(a) - step(a) / 2, last(a) + step(a) / 2)
extent_arr(A::AbstractMatrix) = (extent_ax(axes(A, 1))..., extent_ax(axes(A, 2))...)  # regular arrays, OffsetArrays, (...?)


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

"""    imshow_ax(A::Matrix, [colorbar::ColorBar]; ax=plt.gca(), [norm], [cmap::Symbol], background_val=0, [...])

Display the `A` matrix as an image, so that plot coordinates of each pixel correspond to its "coordinates" in the matrix.

For `KeyedArray`s `axiskeys(A)` become coordinates. They should be regularly spaced ranges.
For other arrays `axes(A)` become coordinates. Works with regular `Array`s, `OffsetArray`s, ....

`norm`: a `matplotlib` norm, or an object with `get_mpl_norm(A, norm)` defined. E.g., a `SymLog`.

Extra `kwargs` not listed in the signature are passed to `matplotlib`'s `imshow`.
"""
function imshow_ax(A::AbstractMatrix, colorbar=nothing; ax=plt.gca(), norm=nothing, cmap=nothing, background_val=0, kwargs...)
    plt.sca(ax)
    norm = get_mpl_norm(A, norm)
    isnothing(background_val) || ax.set_facecolor(plt.get_cmap(cmap)(norm(background_val)))
    mappable = plt.imshow(
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
    return mappable
end

# XXX: generalize somehow? like axiskeys(pcolormesh)(A) or ...?
function plot_ax end
function fill_between_ax end
function pcolormesh_ax end

"""    axplotfunc(f; ax=plt.gca(), n=10, [plot() kwargs...])
Plot `y = f(x)` within the current axis limits. Uses `n` points that uniformly split the whole `x` interval. """
function axplotfunc(f; ax=plt.gca(), n=10, kwargs...)
    lims = ax.get_xlim()
    xs = range(minimum(lims), maximum(lims); length=n)
    keep_plt_lims() do
        ax.plot(xs, f.(xs); kwargs...)
    end
end

"""    label_log_scales(which; ax=plt.gca(), muls=[1, 2, 5], base_label=10, base_data=10)
Add ticks and their labels assuming that data values are `log(base_data, x)` of actual values.
`which` should contain `x` and/or `y`.
"""
function label_log_scales(which; ax=plt.gca(), muls=[1, 2, 5], base_data=10, base_label=10)
    keep_plt_lims() do
        map(which) do w
            lims = getproperty(ax, Symbol(:get_, w, :lim))()
            ticks = [
                round(m * base_label^p, sigdigits=5)  # overcome floating point errors
                for p in floor(lims[1] * log(base_label, base_data)):ceil(lims[2] * log(base_label, base_data))
                for m in muls
            ]
            getproperty(ax, Symbol(:set_, w, :ticks))(log.(base_data, ticks))
            getproperty(ax, Symbol(:set_, w, :ticklabels))(ticks)
        end
    end
end

"""    draw_text_along(xy, str, xys; offset_pixels=0, ...)
Draw text at `xy` and rotate it along the `xys` curve.
Text is made parallel to the direction between two points in `xys` closest to `xy`.
"""
function draw_text_along(xy, str::AbstractString, xys; offset_pixels=0, kwargs...)
    a, b = first(sort(xys; by=p -> hypot((p .- xy)...)), 2)
    a2b = b .- a
    angle = atand(a2b[2], a2b[1])
    trans_angle = plt.gca().transData.transform_angles([angle], reshape(collect(xy), (1, 2)))[1]
    trans_angle = Circular.center_angle(trans_angle, at=0, range=180)
    s_, c_ = sincosd(angle)
    s, c = sincosd(trans_angle)

    data_to_points = plt.gca().transData
    xy_ = data_to_points.inverted().transform(data_to_points.transform(xy) .+ offset_pixels .* (s, -c))

    plt.text(xy_..., str; rotation=trans_angle, va=:top, ha=:center, rotation_mode=:anchor, kwargs...)
end

"""    add_zoom_patch(axA, axB, dir=:horizontal or :vertical; color=:k)

Connect two axes, `axA` and `axB`, with lines indicating difference of their scales. Also draws a rec

Currently assumes that `axA` has smaller limits, it should be the zoomed in version of `axB`.
"""
function add_zoom_patch(axA, axB, dir::Symbol; color=:k)
    @assert axA.figure == axB.figure
    fig = axA.figure
    xl = axA.get_xlim()
    yl = axA.get_ylim()

    axB.add_artist(matplotlib.patches.Rectangle((xl[1], yl[1]), xl[2] - xl[1], yl[2] - yl[1]; facecolor=:none, edgecolor=color))
    xys = dir == :horizontal ? [((xl[1], yl[1]), (xl[2], yl[1])), ((xl[1], yl[2]), (xl[2], yl[2]))] :
          dir == :vertical   ? [((xl[1], yl[1]), (0, 1)), ((xl[2], yl[1]), (1, 1))] :
          error("unknown dir = $dir")
    for (xyA, xyB) in xys
        fig.add_artist(matplotlib.patches.ConnectionPatch(;
            xyA, xyB,
            coordsA="data", coordsB="data",
            axesA=axB, axesB=axA,
            color, ls=":",
            zorder=0.1
        ))
    end
end

end
