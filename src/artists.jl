function ScalebarArtist(scales; target_ax_frac=0.25, muls=Real[1, 2, 5, 10, 20, 50, 100, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01], ax=plt.gca(), color=:k, loc="lower center", sep=2.5)
	ax_size_dataunits = (ax.transAxes + ax.transData.inverted()).transform((1, 1))[1] |> abs

	boxes = map(scales) do (units_in_dataunit, unitstr)
		mul = argmin(m -> abs(units_in_dataunit * m - target_ax_frac * ax_size_dataunits), muls)
		length_dataunits = units_in_dataunit * mul
		
		box = matplotlib.offsetbox.AuxTransformBox(ax.transData)
		box.add_artist(
			matplotlib.lines.Line2D([0, length_dataunits], [0, 0]; color)
		)
		label = matplotlib.offsetbox.TextArea("$mul $unitstr"; textprops=Dict(pairs((;color))...))
		
		matplotlib.offsetbox.VPacker(;
			children=[box, label],
			align=:center, pad=0, sep
		)
	end

	box = matplotlib.offsetbox.VPacker(;
		children=boxes,
		align=:center, pad=0, sep=2*sep
	)
    return matplotlib.offsetbox.AnchoredOffsetbox(;
		child=box,
		loc, pad=0.1, borderpad=0.5, frameon=false
	)
end
