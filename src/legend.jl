"""    legend_inline_right(; [ax=plt.gca()], [fig=plt.gcf()])
Display a "legend" of all labeled lines and fills on the right of the axes, at the `y` coordinates of the corresponding lines. """
function legend_inline_right(; ax=plt.gca(), fig=plt.gcf())
    # adapted from https://github.com/nschloe/matplotx/blob/main/src/matplotx/_labels.py
    ax_pos = ax.get_position()
    ax_height_inches = (ax_pos.y1 - ax_pos.y0) * fig.get_size_inches()[1]
    # "font.size" in pt: 1 pt = 1/72 inches
    fontsize_axunits = (matplotlib.rcParams["font.size"] / 72) / ax_height_inches

    xl = ax.get_xlim()  # sometimes, transforms are not "initialized" (?) without calling this function
    x_increasing = xl[2] >= xl[1]
    transDataAxes = ax.transData + ax.transAxes.inverted()
    @p begin
        plt.gca().get_children()
        filter(!startswith(string(_.get_label()), "_"))
        filtermap() do obj
            r = if pyisinstance(obj, matplotlib.collections.PolyCollection) || pyisinstance(obj, matplotlib.collections.PathCollection)
                # fill_between
                # scatter
                xy = @p begin
                    obj.get_paths()
                    only
                    eachrow(__.vertices)
                    collect
                    @aside mx = maximum(_[1])
                    filter(_[1] == mx)
                    unique  # fill_between repeat the upper point
                    map(transDataAxes.transform)
                    mean
                end
                ec = mpl_color(HSV, obj.get_edgecolor() |> eachrow |> only)
                fc = mpl_color(HSV, obj.get_facecolor() |> eachrow |> only)
                color = ec.v < fc.v ? ec : fc
                (; label=obj.get_label(), xy, color)
            elseif pyisinstance(obj, matplotlib.lines.Line2D)
                # plot, hline
                xy = @p begin
                    obj.get_xydata()
                    eachrow
                    collect
                    filter(x_increasing ? _[1] <= xl[2] : _[1] >= xl[2])
                    x_increasing ? maximum(__) : minimum(__)
                    transDataAxes.transform()
                end
                (; label=obj.get_label(), xy, color=obj.get_color() |> mpl_color)
            elseif pyisinstance(obj, matplotlib.patches.Polygon)
                # hspan
                xy = @p begin
                    obj.get_xy()
                    eachrow
                    collect
                    filter(x_increasing ? _[1] <= xl[2] : _[1] >= xl[2])
                    @aside mxy = x_increasing ? maximum(__) : minimum(__)
                    filter(_[1] == mxy[1])
                    map(transDataAxes.transform)
                    mean
                end
                ec = mpl_color(HSV, obj.get_edgecolor())
                fc = mpl_color(HSV, obj.get_facecolor())
                color = ec.v < fc.v ? ec : fc
                (; label=obj.get_label(), xy, color)
            else
                return nothing
            end
            @reset r.xy[2] = clamp(r.xy[2], 0, 1)
            @reset r.color = alphacolor(r.color, 1)
        end
        @aside isempty(__) && return
        @aside nlines = map(x -> length(split(x.label, '\n')), __)
        @aside @_ min_dists = 1.7 * fontsize_axunits * [(nlines[begin:end-1] + nlines[begin+1:end]) / 2; nlines[end]]
        move_min_distance(__, @optic(_.xy[2]); min_dists)
        map() do _
            plt.text(
                1.01, _.xy[2], _.label;
                transform=ax.transAxes, va=:center, _.color,
                bbox=Dict(:boxstyle => "square,pad=1", :alpha => 0))
        end
    end
end

function move_min_distance(targets, o; min_dists)
    IX = sortperm(targets; by=o)
    targets_sort = targets[IX]

    n = length(targets)
    x0_min = o(first(targets_sort)) - sum(min_dists)
    A = tril(ones(n, n))
    b = o.(targets_sort) .- (x0_min .+ [0; cumsum(min_dists)[begin:end-1]])

    out = nonneg_lsq(A, b) |> vec
    sol = cumsum(out) .+ x0_min .+ [0; cumsum(min_dists)[begin:end-1]]

    map(targets, sol[invperm(IX)]) do tgt, x
        set(tgt, o, x)
    end
end
