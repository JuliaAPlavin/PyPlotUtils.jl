### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ 242110bc-76c0-11ec-0187-9d409aa82de8
begin
	using Revise
	import Pkg
	eval(:(Pkg.develop(path="..")))
	Pkg.resolve()
	using PyPlotUtils
end

# ╔═╡ 8739c218-bfdd-4a02-85f7-bffeec4f1530
using DirectionalStatistics

# ╔═╡ 0ecf5c27-6d6e-4a22-9979-f1f9b9a5396b
using AstroCatalogUtils

# ╔═╡ b8d50eeb-32fe-463c-8944-4265a42c3aa6
using OffsetArrays, AxisKeys

# ╔═╡ 2b2d10b2-50ec-4ff5-8845-fdbf0b747824
using Unitful, UnitfulAngles

# ╔═╡ ca76225d-d1ba-408c-9744-05c759b39564
using VLBIData

# ╔═╡ 6789adfc-642e-4d5f-bbfd-281848abbc9d
using DataPipes

# ╔═╡ 3300253e-3139-442a-aa11-4b530206e4a5
using PyFormattedStrings

# ╔═╡ 6d99bdd6-2ebe-4e76-aee2-d1a189e19c0d
using ColorSchemes

# ╔═╡ b6e6913a-df63-4be3-b467-fb3a375fcd00
using Accessors

# ╔═╡ f90e39fd-a2d0-4cab-ab21-d554a49702b0
using PlutoUI

# ╔═╡ 56a74209-309d-4f43-8bd3-e0a041d15c26
using Colors

# ╔═╡ ba62af69-f903-4793-9061-6be3acf227d5
md"""
This notebook shows usage examples for functions in the `PyPlotUtils.jl` package. Each example is preceded by docstrings of relevant functions.

More real-world usage is shown in [InterferometricModels](https://aplavin.github.io/InterferometricModels.jl/test/examples.html) and [VLBIData](https://aplavin.github.io/VLBIData.jl/test/examples.html) package examples.
"""

# ╔═╡ 7a3a7642-60a5-4c1b-bbf6-25b1a665d7cd


# ╔═╡ 4275dc41-84af-4b7b-a530-f80beb1aac78
@doc pyplot_style!

# ╔═╡ b9891544-ad67-490a-814d-15fa3ece154c
pyplot_style!()

# ╔═╡ 4df70632-9661-40d0-b07e-3373e16138f4
@doc keep_plt_lims

# ╔═╡ 121b2529-8eeb-4fbb-97b6-442642cc072f
@doc ScalebarArtist

# ╔═╡ a01deb47-6d4a-4659-853e-e6e61b198111
let
	plt.figure()
	plt.plot(rand(20))
	keep_plt_lims() do
		plt.plot(rand(30))
	end
	plt.gca().add_artist(ScalebarArtist([(10, "km")]))
	plt.gcf()
end

# ╔═╡ c0d9c6d8-09f2-4975-ab6a-ed100dc7d382
let
	fig, ax = plt.subplots(1, 4, figsize=(15, 3))
	xs = @p [0:1e-5:1e-3; 0:1e-3:0.1; 0:0.1:10; 0.10:1000] |> sort |> filter(_ > 0)
	ys = sin.(1 ./ xs)
	for (i, a) in ax |> enumerate
		plt.sca(a)
		plt.plot(xs, ys)
		plt.xlim(0, [1e-3, 0.1, 10, 1000][i])
		plt.gca().add_artist(ScalebarArtist([(100, x -> x > 1e3 ? f"{x/1e3:d} km" : f"{x} m")]))
	end
	plt.gcf()
end

# ╔═╡ 98187a4d-40c9-4aaa-a51f-def814fb7194
let
	fig, ax = plt.subplots(1, 4, figsize=(15, 6))
	xs = @p [0:1e-5:1e-3; 0:1e-3:0.1; 0:0.1:10; 0.10:1000] |> sort |> filter(_ > 0)
	ys = sin.(1 ./ xs)
	for (i, a) in ax |> enumerate
		plt.sca(a)
		plt.plot(ys, xs)
		plt.ylim(0, [1e-3, 0.1, 10, 1000][i])
		plt.gca().add_artist(ScalebarArtist([(1, "x"), (100, x -> x > 1e3 ? f"{x/1e3:d} km" : f"{x} m")]; which=:y))
	end
	for (a, b) in zip(ax[1:end-1], ax[2:end])
		add_zoom_patch(a, b, :horizontal)
	end
	plt.gcf()
end

# ╔═╡ 0a3b34ac-7db7-48c9-90ad-5a6a674710fb
@doc set_xylims

# ╔═╡ 167c61c0-dda1-481c-80bd-a113eec96392
@doc set_xylabels(x, y)

# ╔═╡ ce27aab5-7bb6-4b9a-8159-5e017437bc17
let
	plt.figure()
	plt.plot(rand(20), rand(20))
	plt.gca().set_aspect(:equal)
	set_xylims((0 ± 1)^2, inv=:x)
	set_xylabels("Aaa", "Bbb", inline=true)
	plt.gcf()
end

# ╔═╡ 43787905-66d8-4aba-bf5d-88da7a1ea48b
@doc imshow_ax

# ╔═╡ 23806204-098d-4865-9b11-59e3457857a2
@doc set_xylabels(::Matrix)

# ╔═╡ b5161436-535d-44ef-aa2e-14880636a9cf
let
	A = rand(3, 6)
	figs = []
	
	plt.figure()
	imshow_ax(A; cmap=:inferno)
	push!(figs, plt.gcf())
	
	plt.figure()
	imshow_ax(OffsetArray(A, -1:1, -1:4); cmap=:inferno)
	push!(figs, plt.gcf())
	
	plt.figure()
	imshow_ax(KeyedArray(A, (-1:1, -1:4)); cmap=:inferno)
	push!(figs, plt.gcf())
	
	plt.figure()
	kA = KeyedArray(A, ra=-1:1, dec=-1.25:0.5:1.25)
	imshow_ax(kA; cmap=:inferno)
	set_xylims((-1.5..1.5)^2; inv=:x)
	xylabels(kA)
	push!(figs, plt.gcf())
	
	plt.figure()
	kA = KeyedArray(A, ra=(-1:1)u"mas", dec=(-1.25:0.5:1.25)u"mas")
	imshow_ax(kA; cmap=:inferno)
	xylabels(kA)
	push!(figs, plt.gcf())
	
	plt.figure()
	imshow_ax(kA; cmap=:inferno)
	xylabels(kA; inline=true)
	push!(figs, plt.gcf())

	figs
end

# ╔═╡ 77dd7281-7fa2-492b-908e-e819b09a078b
let
	plt.figure()
	fimg = VLBI.load(joinpath(dirname(pathof(VLBI)), "../test/data/map.fits"))
	imshow_ax(fimg.data, ColorBar(unit="Jy"); norm=SymLog(), cmap=:inferno)
	xylabels(fimg.data, inline=true)
	set_xylims((0±70)^2)
	plt.gcf()
end

# ╔═╡ c95d28bd-5ad5-4f40-b57c-02f039951a8c
@doc legend_inline_right

# ╔═╡ dabeff3d-f0eb-47c7-be65-f47a19201597
let
	plt.figure()
	plt.plot(1:30, 3randn(30) ./ (11:40); label="Curve A")
	plt.plot(1:30, 3randn(30) ./ (11:40); label="Curve B", color="#f304")
	plt.plot(1:30, 3 .+ randn(30); label="Another curve")
	plt.fill_between(1:30, 2 .+ randn(30), 6 .+ randn(30); alpha=0.3, label="Filled area", color=:C2)
	legend_inline_right()
	plt.gcf()
end

# ╔═╡ cd3de117-4b80-44f5-aee9-595d435af230
@doc axplotfunc

# ╔═╡ ac5012ec-2666-4d5d-956a-223142fc3441
let
	plt.figure()
	xs = randn(100)
	plt.scatter(xs, xs .+ randn.(); color=:grey)
	axplotfunc(x -> x; label="y = 0.5x")
	axplotfunc(x -> 2x; label="y = 3x")
	plt.xlim(plt.xlim()[1], 1)
	legend_inline_right()
	plt.gcf()
end

# ╔═╡ 2ca3ab3b-2c63-411f-8968-d2cde2c0c8ac
let
	plt.figure()
	xs = randn(100)
	plt.scatter(xs, xs .+ randn.(); color=:grey)
	axplotfunc(x -> x; label="y = 0.5x")
	axplotfunc(x -> 2x; label="y = 3x")
	plt.xlim(-1, plt.xlim()[2])
	plt.gca().invert_xaxis()
	legend_inline_right()
	plt.gcf()
end

# ╔═╡ afbe870a-7333-41ae-bad8-1755a775d71d
@doc label_log_scales

# ╔═╡ cd2c4fbd-6212-4e83-88fa-5af966d36335
let
	plt.figure()
	xs = randn(100)
	plt.scatter(xs, xs .+ randn.(); color=:grey)
	label_log_scales([:x, :y]; base_data=ℯ)
	plt.gcf()
end

# ╔═╡ 89d9a38c-6290-4233-95ae-018cd1b200b6
let
	plt.figure()
	xys = @p 0:0.1:2π |> map((1.5 - cos(_), sin(_)))
	plt.plot(first.(xys), last.(xys))
	plt.ylim(-2, 2)
	plt.xscale(:log)
	for xy in xys[1:3:end]
		draw_text_along(xy, "abc", xys; offset_pixels=5, color=:green)
	end
	plt.gcf()
end

# ╔═╡ 25907b7a-f3a2-4d9d-b294-68a5069d7e55


# ╔═╡ 43a144d7-ecae-4629-acc1-ad97d0fe8227
let
	plt.figure(figsize=(10, 6))
	plt.subplot(projection="mollweide")

	A = [(x, sin(x)) for x in [0.5:0.3:π; -π:0.3:0.5]]
	plt.scatter(first.(A), last.(A), s=5)
	A = Circular.wrap_curve_closed(first, A; rng=-π..π)
	plt.plot(first.(A), last.(A))
	
	A = AstroCatalogUtils.boundary_radec(CoordsWErr((0., 1.3), ErrorCircular(0.5)); n=10)
	plt.scatter(first.(A), last.(A), s=5)
	A = Circular.wrap_curve_closed(first, A; rng=-π..π)
	plt.plot(first.(A), last.(A))
	
	A = AstroCatalogUtils.boundary_radec(CoordsWErr((2.9, 0.5), ErrorCircular(0.5)); n=10)
	plt.scatter(first.(A), last.(A), s=5)
	A = Circular.wrap_curve_closed(first, A; rng=-π..π)
	plt.plot(first.(A), last.(A))
	
	plt.gcf()
end

# ╔═╡ a85a78af-db46-4891-9885-17d0c30c5243


# ╔═╡ 481829a3-8aa7-4ac9-8d67-99a366a541f9


# ╔═╡ 6c28142a-61b5-4391-93b4-7f6aa65479ff


# ╔═╡ fe65bbff-b945-490d-b163-a80ced9e16f7


# ╔═╡ b586f6cd-2995-4a37-a0a1-89e2e1c86912


# ╔═╡ 9b357314-2505-4b7b-bc70-4b486f7b0fb1


# ╔═╡ 4cbb20ea-1e42-42d4-a38a-5bede64d7416
md"""
Color manipulation tryout...
"""

# ╔═╡ 6d9a2e34-798d-4493-8d18-63396822b2ad
mpl_color("#0f0f0f80")

# ╔═╡ 69ab484b-f880-4cea-8e71-78e6454a04ac
let
	plt.figure()
	plt.plot(rand(20), color=mpl_color(LCHuv, :C0))
	plt.plot(rand(20), color=@set mpl_color(LCHuv, :C0).l *= 0.4)
	plt.plot(rand(20), color=@set mpl_color(LCHuv, :C0).l *= 1.6)
	plt.plot(rand(20), color=alphacolor(mpl_color(LCHuv, :C0), 0.2))
	plt.gcf()
end

# ╔═╡ 4c88db25-34d2-4920-ba4e-a1e76e991223
(@set mpl_color(LCHuv, :C0).l *= 0.2)

# ╔═╡ 9daf1762-5215-4450-8888-4580cfb49341
convert(XYZ, @set mpl_color(LCHuv, :C0).l *= 0.2) |> Dump

# ╔═╡ 31d5ffd1-1ce6-487f-a607-43c87dbc6e25
map(ColorSchemes.tab10) do c
	c = convert(LCHuv, c)
	map([0.5, 0.75, 1, 1.25, 1.5]) do m
		@set c.l = m * 50
	end
end

# ╔═╡ d96687c5-eeaa-4e1c-859c-a757d0d379c2


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Accessors = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
AstroCatalogUtils = "705829cc-62c6-4882-a4ec-bd7361a5ccd3"
AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
DataPipes = "02685ad9-2d12-40c3-9f73-c6aeda6a7ff5"
DirectionalStatistics = "e814f24e-44b0-11e9-2fd5-aba2b6113d95"
OffsetArrays = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PyFormattedStrings = "5f89f4a4-a228-4886-b223-c468a82ed5b9"
PyPlotUtils = "5384e752-6c47-47b3-86ac-9d091b110b31"
Revise = "295af30f-e4ad-537b-8983-00126c2a3abe"
Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"
UnitfulAngles = "6fb2a4bd-7999-5318-a3b2-8ad61056cd98"
VLBIData = "679fc9cc-3e84-11e9-251b-cbd013bd8115"

[compat]
Accessors = "~0.1.7"
AstroCatalogUtils = "~0.4.16"
AxisKeys = "~0.2.4"
ColorSchemes = "~3.19.0"
Colors = "~0.12.8"
DataPipes = "~0.2.16"
DirectionalStatistics = "~0.1.15"
OffsetArrays = "~1.12.7"
PlutoUI = "~0.7.30"
PyFormattedStrings = "~0.1.10"
PyPlotUtils = "~0.1.2"
Revise = "~3.3.1"
Unitful = "~1.11.0"
UnitfulAngles = "~0.6.2"
VLBIData = "~0.3.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0-rc4"
manifest_format = "2.0"
project_hash = "9e67639ad87ee8c0e69cd87c6f7c234d72041d8d"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Accessors]]
deps = ["Compat", "CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Requires", "Test"]
git-tree-sha1 = "c877a35749324754d3c8fffb09fc1f9db144ff8f"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.18"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArraysOfArrays]]
deps = ["Adapt", "ChainRulesCore", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "33177b879bb757a900b035eb8b49b4e8af938572"
uuid = "65a8f2f4-9b39-5baf-92e2-a9cc46fdf018"
version = "0.6.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AstroAngles]]
git-tree-sha1 = "41621fa5ed5f7614b75eea8e0b3cfd967b284c87"
uuid = "5c4adb95-c1fc-4c53-b4ea-2a94080c53d2"
version = "0.1.3"

[[deps.AstroCatalogUtils]]
deps = ["Accessors", "AstroAngles", "AstroDataBase", "DataPipes", "DirectionalStatistics", "Distances", "DocStringExtensions", "FlexiJoins", "InverseFunctions", "LinearAlgebra", "NearestNeighbors", "Parameters", "PyFormattedStrings", "Random", "SkyCoords", "StaticArrays", "StructArrays"]
git-tree-sha1 = "21ed19bf3e2b7a270ddf5fd4189209849c2a38b5"
uuid = "705829cc-62c6-4882-a4ec-bd7361a5ccd3"
version = "0.4.16"

[[deps.AstroDataBase]]
deps = ["Accessors", "AxisKeys", "DataPipes", "Dates", "OrderedCollections", "SliceThrough"]
git-tree-sha1 = "fa8525252c819f57214eb432f23cc64e90571fed"
uuid = "cc88de29-2d75-48be-97ee-dd03a6b97b76"
version = "0.1.29"

[[deps.AxisKeys]]
deps = ["AbstractFFTs", "ChainRulesCore", "CovarianceEstimation", "IntervalSets", "InvertedIndices", "LazyStack", "LinearAlgebra", "NamedDims", "OffsetArrays", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "945ec1c6b21f166b1f6f3cf628b770c5a253fb73"
uuid = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
version = "0.2.4"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CFITSIO]]
deps = ["CFITSIO_jll"]
git-tree-sha1 = "8425c47db102577eefb93cb37b4480e750116b0d"
uuid = "3b1b4be9-1499-4b22-8d78-7db3344d1961"
version = "1.4.1"

[[deps.CFITSIO_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "9c91a9358de42043c3101e3a29e60883345b0b39"
uuid = "b3e40c51-02ae-5482-8a39-3ace5868dcf4"
version = "4.0.0+0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "80ca332f6dcb2508adba68f22f551adb2d00a624"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.3"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "6d4fa04343a7fc9f9cb9cff9558929f3d2752717"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.0.9"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "924cdca592bc16f14d2f7006754a621735280b74"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.1.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.CompositeTypes]]
git-tree-sha1 = "d5b014b216dc891e81fea299638e4c10c657b582"
uuid = "b152e2b5-7a66-4b01-a709-34e65c35f657"
version = "0.1.2"

[[deps.CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "6e47d11ea2776bc5627421d59cdcc1296c058071"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.7.0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "59d00b3139a9de4eb961057eabb65ac6522be954"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.0"

[[deps.CovarianceEstimation]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "a3e070133acab996660d31dcf479ea42849e368f"
uuid = "587fd27a-f159-11e8-2dae-1979310e6154"
version = "0.2.7"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataPipes]]
deps = ["Accessors", "SplitApplyCombine"]
git-tree-sha1 = "16df65e133f714831c9a6fe1aa62dd1cd1d728ba"
uuid = "02685ad9-2d12-40c3-9f73-c6aeda6a7ff5"
version = "0.2.16"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DateFormats]]
deps = ["Dates", "DocStringExtensions", "InverseFunctions"]
git-tree-sha1 = "5385eb5aa41b70000d76a302f94da491caa00ae9"
uuid = "44557152-fe0a-4de1-8405-416d90313ce6"
version = "0.1.14"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Dictionaries]]
deps = ["Indexing", "Random"]
git-tree-sha1 = "7669d53b75e9f9e2fa32d5215cb2af348b2c13e2"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.21"

[[deps.DirectionalStatistics]]
deps = ["Accessors", "IntervalSets", "InverseFunctions", "LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "6115320dc2a15ab0f5916bcadf27c17f683df8ce"
uuid = "e814f24e-44b0-11e9-2fd5-aba2b6113d95"
version = "0.1.15"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c5544d8abb854e306b7b2f799ab31cdba527ccae"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.0"

[[deps.DomainSets]]
deps = ["CompositeTypes", "IntervalSets", "LinearAlgebra", "StaticArrays", "Statistics"]
git-tree-sha1 = "ac425eea956013b51e7891bef3c33684b7d37029"
uuid = "5b8099bc-c8ec-5219-889f-1d9e522a28bf"
version = "0.5.11"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FITSIO]]
deps = ["CFITSIO", "Printf", "Reexport", "Tables"]
git-tree-sha1 = "e6033823834ec0070125120d4d4a1234f1826a47"
uuid = "525bcba6-941b-5504-bd06-fd0dc1a4d2eb"
version = "0.16.12"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.FlexiJoins]]
deps = ["Accessors", "ArraysOfArrays", "DataAPI", "DataPipes", "IntervalSets", "NearestNeighbors", "Requires", "SplitApplyCombine", "Static", "StructArrays", "Tables"]
git-tree-sha1 = "9a78ca581306ab229acc3337c0f3900e6cd173e4"
uuid = "e37f2e79-19fa-4eb7-8510-b63b51fe0a37"
version = "0.1.23"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InterferometricModels]]
deps = ["Accessors", "IntervalSets", "LinearAlgebra", "StaticArrays", "Unitful", "UnitfulAstro"]
git-tree-sha1 = "7594d795d0404c7485fa4a9a1173facabfbad3fa"
uuid = "b395d269-c2ec-4df6-b679-36919ad600ca"
version = "0.1.7"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "57af5939800bce15980bddd2426912c4f83012d8"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.1"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "52617c41d2761cc05ed81fe779804d3b7f14fff7"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.13"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyStack]]
deps = ["LinearAlgebra", "NamedDims", "OffsetArrays", "Test", "ZygoteRules"]
git-tree-sha1 = "a8bf67afad3f1ee59d367267adb7c44ccac7fdee"
uuid = "1fad7336-0346-5a1a-a56f-a06ba010965b"
version = "0.0.7"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7c88f63f9f0eb5929f15695af9a4d7d3ed278a91"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.16"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NamedDims]]
deps = ["AbstractFFTs", "ChainRulesCore", "CovarianceEstimation", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "467b53bf3c1f5f0612e0bc430b7afedc64652822"
uuid = "356022a1-0364-5f58-8944-0da4b18d706f"
version = "0.2.49"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "0e353ed734b1747fc20cd4cba0edd9ac027eff6a"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.NonNegLeastSquares]]
deps = ["Distributed", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "1271344271ffae97e2855b0287356e6ea5c221cc"
uuid = "b7351bd1-99d9-5c5d-8786-f205a815c4d7"
version = "0.4.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "1ea784113a6aa054c5ebd95945fa5e52c2f378e7"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.7"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0044b23da09b5608b4ecacb4e5e6c6332f833a7e"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "1fc929f47d7c151c839c5fc1375929766fb8edcc"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.93.1"

[[deps.PyFormattedStrings]]
deps = ["Printf"]
git-tree-sha1 = "427aadbcb003bd2b39c87caa5177dded65f81ddf"
uuid = "5f89f4a4-a228-4886-b223-c468a82ed5b9"
version = "0.1.10"

[[deps.PyPlot]]
deps = ["Colors", "LaTeXStrings", "PyCall", "Sockets", "Test", "VersionParsing"]
git-tree-sha1 = "14c1b795b9d764e1784713941e787e1384268103"
uuid = "d330b81b-6aea-500a-939a-2ce795aea3ee"
version = "2.10.0"

[[deps.PyPlotUtils]]
deps = ["Accessors", "AxisKeys", "Colors", "DataPipes", "DirectionalStatistics", "DomainSets", "IntervalSets", "LinearAlgebra", "NonNegLeastSquares", "PyCall", "PyPlot", "StatsBase", "Unitful"]
path = "../../home/aplavin/.julia/dev/PyPlotUtils"
uuid = "5384e752-6c47-47b3-86ac-9d091b110b31"
version = "0.1.15"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "c73149ff75d4efb19b6d77411d293ae8fb55c58e"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.3.4"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SkyCoords]]
deps = ["AstroAngles", "ConstructionBase", "StaticArrays"]
git-tree-sha1 = "3302abfbde42db0c029e86d6155775b474a536d3"
uuid = "fc659fc5-75a3-5475-a2ea-3da92c065361"
version = "1.0.1"

[[deps.SliceThrough]]
deps = ["Accessors", "AxisKeys", "DataPipes", "IntervalSets", "SplitApplyCombine", "StructArrays"]
git-tree-sha1 = "ff055551c8f0f60a2f53d4df56312e1743670e36"
uuid = "91eba6c1-ac83-4f77-b15d-b014ec3c8051"
version = "0.1.6"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.SplitApplyCombine]]
deps = ["Dictionaries", "Indexing"]
git-tree-sha1 = "48f393b0231516850e39f6c756970e7ca8b77045"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.2.2"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "f94f9d627ba3f91e41a815b9f9f977d729e2e06f"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.7.6"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "23368a3313d12a2326ad0035f0db0c0966f438ef"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "66fe9eb253f910fe8cf161953880cfdaef01cdf0"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.0.1"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "2c11d7290036fe7aac9038ff312d3b3a2a5bf89e"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.4.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "472d044a1c8df2b062b23f222573ad6837a615ba"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.19"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "ec47fb6069c57f1cee2f67541bf8f23415146de7"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.11"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "b649200e887a487468b71821e2644382699f1b0f"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.11.0"

[[deps.UnitfulAngles]]
deps = ["Dates", "Unitful"]
git-tree-sha1 = "d6cfdb6ddeb388af1aea38d2b9905fa014d92d98"
uuid = "6fb2a4bd-7999-5318-a3b2-8ad61056cd98"
version = "0.6.2"

[[deps.UnitfulAstro]]
deps = ["Unitful", "UnitfulAngles"]
git-tree-sha1 = "c4e1c470a94063b911fd1b1a204cd2bb34a8cd15"
uuid = "6112ee07-acf9-5e0f-b108-d242c714bf9f"
version = "1.1.1"

[[deps.VLBIData]]
deps = ["AxisKeys", "DataPipes", "DateFormats", "Dates", "DelimitedFiles", "FITSIO", "InterferometricModels", "PyCall", "PyFormattedStrings", "Reexport", "StaticArrays", "StructArrays", "Tables", "Unitful", "UnitfulAngles", "UnitfulAstro"]
git-tree-sha1 = "7b1ceba291099cdc9cbe9662112bb2a08303ee89"
uuid = "679fc9cc-3e84-11e9-251b-cbd013bd8115"
version = "0.3.10"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─ba62af69-f903-4793-9061-6be3acf227d5
# ╠═7a3a7642-60a5-4c1b-bbf6-25b1a665d7cd
# ╟─4275dc41-84af-4b7b-a530-f80beb1aac78
# ╠═b9891544-ad67-490a-814d-15fa3ece154c
# ╟─4df70632-9661-40d0-b07e-3373e16138f4
# ╟─121b2529-8eeb-4fbb-97b6-442642cc072f
# ╠═a01deb47-6d4a-4659-853e-e6e61b198111
# ╠═c0d9c6d8-09f2-4975-ab6a-ed100dc7d382
# ╠═98187a4d-40c9-4aaa-a51f-def814fb7194
# ╟─0a3b34ac-7db7-48c9-90ad-5a6a674710fb
# ╟─167c61c0-dda1-481c-80bd-a113eec96392
# ╠═ce27aab5-7bb6-4b9a-8159-5e017437bc17
# ╟─43787905-66d8-4aba-bf5d-88da7a1ea48b
# ╟─23806204-098d-4865-9b11-59e3457857a2
# ╠═b5161436-535d-44ef-aa2e-14880636a9cf
# ╠═77dd7281-7fa2-492b-908e-e819b09a078b
# ╟─c95d28bd-5ad5-4f40-b57c-02f039951a8c
# ╠═dabeff3d-f0eb-47c7-be65-f47a19201597
# ╟─cd3de117-4b80-44f5-aee9-595d435af230
# ╠═ac5012ec-2666-4d5d-956a-223142fc3441
# ╠═2ca3ab3b-2c63-411f-8968-d2cde2c0c8ac
# ╟─afbe870a-7333-41ae-bad8-1755a775d71d
# ╠═cd2c4fbd-6212-4e83-88fa-5af966d36335
# ╠═89d9a38c-6290-4233-95ae-018cd1b200b6
# ╠═25907b7a-f3a2-4d9d-b294-68a5069d7e55
# ╠═8739c218-bfdd-4a02-85f7-bffeec4f1530
# ╠═0ecf5c27-6d6e-4a22-9979-f1f9b9a5396b
# ╠═43a144d7-ecae-4629-acc1-ad97d0fe8227
# ╠═a85a78af-db46-4891-9885-17d0c30c5243
# ╠═481829a3-8aa7-4ac9-8d67-99a366a541f9
# ╠═6c28142a-61b5-4391-93b4-7f6aa65479ff
# ╠═242110bc-76c0-11ec-0187-9d409aa82de8
# ╠═b8d50eeb-32fe-463c-8944-4265a42c3aa6
# ╠═2b2d10b2-50ec-4ff5-8845-fdbf0b747824
# ╠═ca76225d-d1ba-408c-9744-05c759b39564
# ╠═6789adfc-642e-4d5f-bbfd-281848abbc9d
# ╠═3300253e-3139-442a-aa11-4b530206e4a5
# ╠═fe65bbff-b945-490d-b163-a80ced9e16f7
# ╠═b586f6cd-2995-4a37-a0a1-89e2e1c86912
# ╠═9b357314-2505-4b7b-bc70-4b486f7b0fb1
# ╟─4cbb20ea-1e42-42d4-a38a-5bede64d7416
# ╠═6d99bdd6-2ebe-4e76-aee2-d1a189e19c0d
# ╠═b6e6913a-df63-4be3-b467-fb3a375fcd00
# ╠═6d9a2e34-798d-4493-8d18-63396822b2ad
# ╠═69ab484b-f880-4cea-8e71-78e6454a04ac
# ╠═4c88db25-34d2-4920-ba4e-a1e76e991223
# ╠═9daf1762-5215-4450-8888-4580cfb49341
# ╠═f90e39fd-a2d0-4cab-ab21-d554a49702b0
# ╠═31d5ffd1-1ce6-487f-a607-43c87dbc6e25
# ╠═d96687c5-eeaa-4e1c-859c-a757d0d379c2
# ╠═56a74209-309d-4f43-8bd3-e0a041d15c26
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
