"""    ScalebarArtist(scales; target_ax_frac=0.25, [muls], ax=plt.gca(), color=:k, loc="lower center", sep=2.5)
Create a `matplotlib` `artist` that contains a scalebar with its label. Multiple scalebars are supported, one for each element of `scales = [(units_in_dataunit, unit_label), ...]`.
"""
function ScalebarArtist(scales;
		target_ax_frac=0.25,
		muls=[x*p for p in Real[1e-9, 1e-8, 1e-7, 1e-5, 1e-4, 1e-3, 0.01, 0.1, 1, 10, 100, 1000, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9] for x in [1, 2, 5]],
		ax=plt.gca(), color=:k, sep=2.5,
		which=:x, loc=["lower center", "center right"][_resolve_which(which)],
	)
	which = _resolve_which(which)
    ax_size_dataunits = (ax.transAxes + ax.transData.inverted()).transform((1, 1))[which] |> abs

    boxes = map(scales) do (units_in_dataunit, unitspec)
        mul = argmin(m -> abs(1 / units_in_dataunit * m - target_ax_frac * ax_size_dataunits), muls)
        length_dataunits = 1 / units_in_dataunit * mul

        box = matplotlib.offsetbox.AuxTransformBox(ax.transData)
        box.add_artist(
            which == 1 ?
				matplotlib.lines.Line2D([0, length_dataunits], [0, 0]; color) :
				matplotlib.lines.Line2D([0, 0], [0, length_dataunits]; color)
        )
        label = matplotlib.offsetbox.TextArea(_scalebar_str(mul, unitspec); textprops=Dict(pairs((; color))...))

        which == 1 ? matplotlib.offsetbox.VPacker(;
			children=[box, label],
			align=:center, pad=0, sep
		) : matplotlib.offsetbox.HPacker(;
			children=[label, box],
			align=:center, pad=0, sep
		)
    end

    box = matplotlib.offsetbox.VPacker(;
        children=boxes,
        align=[:center, :right][which], pad=0, sep=2 * sep
    )
    return matplotlib.offsetbox.AnchoredOffsetbox(;
        child=box,
        loc, pad=0.1, borderpad=0.5, frameon=false
    )
end

_resolve_which(which) = Dict(:x => 1, :y => 2, :horizontal => 1, :vertical => 2, 1 => 1, 2 => 2)[which]

_scalebar_str(mul, unitspec::AbstractString) = "$mul $unitspec"
_scalebar_str(mul, unitspec::Function) = unitspec(mul)
