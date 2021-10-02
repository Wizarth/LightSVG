using Test
using LightDOM
using LightSVG

@testset "validators" begin
	@testset "integer" begin
		# Valid Values
		@test LightSVG.istype(1, :integer)
		@test LightSVG.istype("1", :integer)
		@test LightSVG.istype("-1", :integer)
		@test LightSVG.istype("00000000000", :integer)
		# Invalid values
		@test !LightSVG.istype(1.1, :integer)
		@test !LightSVG.istype("1.1", :integer)
		@test !LightSVG.istype("foo", :integer)
		@test !LightSVG.istype("", :integer)
	end
	@testset "number" begin
		# Valid values
		@test LightSVG.istype(1, :number)
		@test LightSVG.istype("1", :number)
		@test LightSVG.istype("0.1", :number)
		@test LightSVG.istype("0.1e1", :number)
		@test LightSVG.istype(".1e1", :number)

		# Invalid
		@test !LightSVG.istype(1+2im, :number)
		@test !LightSVG.istype("1e1", :number)	# invalid exponent format
		@test !LightSVG.istype("1.e1", :number) # invalid exponent format
		@test !LightSVG.istype("foobar", :number)
		@test !LightSVG.istype("x1", :number)
		@test !LightSVG.istype("1x", :number)
	end
	@testset "length" begin
		# Valid values
		@test LightSVG.istype(1, :length)
		@test LightSVG.istype("1", :length)
		@test LightSVG.istype("0.1", :length)
		@test LightSVG.istype("0.1e1", :length)
		@test LightSVG.istype(".1e1", :length)
		@test LightSVG.istype("1em", :length)
		@test LightSVG.istype("1ex", :length)
		@test LightSVG.istype("1px", :length)
		@test LightSVG.istype("1in", :length)
		@test LightSVG.istype("1cm", :length)
		@test LightSVG.istype("1mm", :length)
		@test LightSVG.istype("1pt", :length)
		@test LightSVG.istype("1pc", :length)
		@test LightSVG.istype("1%", :length)
		# Invalid
		@test LightSVG.istype(1+2im, :length) == false
		@test LightSVG.istype("1e1", :length) == false	# Invalid exponent format
		@test LightSVG.istype("1.e1", :length) == false	# Invalid exponent format
		@test LightSVG.istype("foobar", :length) == false
		@test LightSVG.istype("x1", :length) == false
		@test LightSVG.istype("1x", :length) == false
		@test LightSVG.istype("1pcx", :length) == false
		@test LightSVG.istype("x1pc", :length) == false
	end
	@testset "string" begin
		@test LightSVG.istype("abcd", :string)
		@test LightSVG.istype("", :string)	# This passes, but should it?
		
		@test !LightSVG.istype(1, :string)
		@test !LightSVG.istype(:none, :string)
	end
	@testset "preserve_aspect_ratio" begin
		ratios = [
			"none",
			"xMinYMin",
			"xMidYMin",
			"xMaxYMin",
			"xMinYMid",
			"xMidYMid",
			"xMaxYMid",
			"xMinYMax",
			"xMidYMax",
			"xMaxYMax"
		]
		for ratio in ratios
			@test LightSVG.istype(ratio, :preserve_aspect_ratio)
		end
		suffixes = [" meet", " slice" ]
		for ratio in ratios
			for suffix in suffixes
				@test LightSVG.istype(string(ratio, suffix), :preserve_aspect_ratio)
			end
		end
	end
	@testset "listofnumbers" begin
		# AbstractArray{<:Real}
		@test LightSVG.istype([1], :listofnumbers)
		@test LightSVG.istype([1, 1.1], :listofnumbers)
		@test LightSVG.istype([1, 2, 3], :listofnumbers)

		# Tuple{<:Real...}
		@test LightSVG.istype((1), :listofnumbers)
		@test LightSVG.istype((1, 1.1), :listofnumbers)
		@test LightSVG.istype((1, 2, 3), :listofnumbers)

		# AbstractArray{Any} where all istype(string)
		@test LightSVG.istype([1, 2, "3"], :listofnumbers)
		# Tuple where all istype(string)
		@test LightSVG.istype((1, 2, "3"), :listofnumbers)

		@test LightSVG.istype("1 2 3", :listofnumbers)
		@test LightSVG.istype("1.1 2 3.3", :listofnumbers)
		
		@test !LightSVG.istype("foo", :listofnumbers)
		@test !LightSVG.istype("1 2 foo", :listofnumbers)
		@test !LightSVG.istype("foo 2 3", :listofnumbers)
	end
end

@testset "toprop" begin
	@testset "listofnumbers" begin
		@test LightSVG.toprop([1, 2, 3], :listofnumbers) == "1 2 3"
		@test LightSVG.toprop((1, 2, 3), :listofnumbers) == "1 2 3"
	end
end

@testset "SVG" begin
	@testset "defaults" begin
		svg = SVG()
		@test svg isa Element
		@test haskey(svg.props, :width) == false
		@test haskey(svg.props, :height) == false

		svg = SVG(;width=:auto, height=:auto)
		@test svg isa Element
		@test haskey(svg.props, :width) == false
		@test haskey(svg.props, :height) == false

		svg = SVG(viewBox=Nothing)
		@test haskey(svg.props, :viewBox) == false
	end
	@testset "invalid properties" begin
		@test_throws ErrorException SVG(id=1)	#id must be string
	end
	@testset "lengths" begin
		length = 1

		svg = SVG(;width=length, height=length)
		@test svg isa Element
		@test svg.props[:width] == length
		@test svg.props[:height] == length
	end

	@testset "core attributes" begin
		svg = SVG()
		@test haskey(svg.props, Symbol("xml:base")) == false

		base = "http://example.com/base"
		svg = SVG(;var"xml:base" = base)
		@test get(svg.props, Symbol("xml:base"), Nothing) == base
	end
end
