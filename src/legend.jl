function legend_inline_right(; ax=plt.gca(), fig=plt.gcf())
	# adapted from https://github.com/nschloe/matplotx/blob/main/src/matplotx/_labels.py
	ax_pos = ax.get_position()
	ax_height_inches = (ax_pos.y1 - ax_pos.y0) * fig.get_size_inches()[1]
	# "font.size" in pt: 1 pt = 1/72 inches
	fontsize_axunits = (matplotlib.rcParams["font.size"] / 72) / ax_height_inches
	
    transDataAxes = ax.transData + ax.transAxes.inverted()
	@p begin
		plt.gca().get_children()
		filter(!startswith(string(_.get_label()), "_"))
		filtermap() do obj
			if pyisinstance(obj, matplotlib.collections.PolyCollection)
				xy = @p begin
					obj.get_paths()
					only
					eachrow(__.vertices)
					maximum()
					transDataAxes.transform()
				end
				(; label=obj.get_label(), xy, color=obj.get_edgecolor() |> eachrow |> only)
			elseif pyisinstance(obj, matplotlib.lines.Line2D)
				xy = @p begin
					obj.get_xydata()
					eachrow
					collect
					last
					transDataAxes.transform()
				end
				(; label=obj.get_label(), xy, color=obj.get_color())
			else
				return nothing
			end
		end
		@aside isempty(__) && return
		@aside min_dist = 1.7 * fontsize_axunits * maximum(x -> length(split(x.label, '\n')), __)
		move_min_distance(__, @optic(_.xy[2]); min_dist)
		map() do _
			plt.text(
				1.01, _.xy[2], _.label;
				transform=ax.transAxes, va=:center, _.color,
				bbox=Dict(:boxstyle => "square,pad=1", :alpha => 0))
		end
	end
end

function move_min_distance(targets, o; min_dist::Real)
    IX = sortperm(targets; by=o)
    targets_sort = targets[IX]

    n = length(targets)
    x0_min = o(first(targets_sort)) - n * min_dist
    A = tril(ones(n, n))
    b = o.(targets_sort) .- (x0_min .+ (0:(n-1)) .* min_dist)

    out = nonneg_lsq(A, b) |> vec
    sol = cumsum(out) .+ x0_min .+ (0:(n-1)) .* min_dist

    map(targets, sol[invperm(IX)]) do tgt, x
		set(tgt, o, x)
	end
end
