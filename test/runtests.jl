using Test
using LightDOM
using LightSVG

@testset "validators" begin
	@testset "integer" begin
		# Valid Values
		@test LightSVG.istype(1, Val(:integer))
		@test LightSVG.istype("1", Val(:integer))
		@test LightSVG.istype("-1", Val(:integer))
		@test LightSVG.istype("00000000000", Val(:integer))
		# Invalid values
		@test !LightSVG.istype(1.1, Val(:integer))
		@test !LightSVG.istype("1.1", Val(:integer))
		@test !LightSVG.istype("foo", Val(:integer))
		@test !LightSVG.istype("", Val(:integer))
	end
	@testset "number" begin
		# Valid values
		@test LightSVG.istype(1, Val(:number))
		@test LightSVG.istype("1", Val(:number))
		@test LightSVG.istype("0.1", Val(:number))
		@test LightSVG.istype("0.1e1", Val(:number))
		@test LightSVG.istype(".1e1", Val(:number))

		# Invalid
		@test !LightSVG.istype(1+2im, Val(:number))
		@test !LightSVG.istype("1e1", Val(:number))	# invalid exponent format
		@test !LightSVG.istype("1.e1", Val(:number)) # invalid exponent format
		@test !LightSVG.istype("foobar", Val(:number))
		@test !LightSVG.istype("x1", Val(:number))
		@test !LightSVG.istype("1x", Val(:number))
	end
	@testset "length" begin
		# Valid values
		@test LightSVG.istype(1, Val(:length))
		@test LightSVG.istype("1", Val(:length))
		@test LightSVG.istype("0.1", Val(:length))
		@test LightSVG.istype("0.1e1", Val(:length))
		@test LightSVG.istype(".1e1", Val(:length))
		@test LightSVG.istype("1em", Val(:length))
		@test LightSVG.istype("1ex", Val(:length))
		@test LightSVG.istype("1px", Val(:length))
		@test LightSVG.istype("1in", Val(:length))
		@test LightSVG.istype("1cm", Val(:length))
		@test LightSVG.istype("1mm", Val(:length))
		@test LightSVG.istype("1pt", Val(:length))
		@test LightSVG.istype("1pc", Val(:length))
		@test LightSVG.istype("1%", Val(:length))
		# Invalid
		@test LightSVG.istype(1+2im, Val(:length)) == false
		@test LightSVG.istype("1e1", Val(:length)) == false	# Invalid exponent format
		@test LightSVG.istype("1.e1", Val(:length)) == false	# Invalid exponent format
		@test LightSVG.istype("foobar", Val(:length)) == false
		@test LightSVG.istype("x1", Val(:length)) == false
		@test LightSVG.istype("1x", Val(:length)) == false
		@test LightSVG.istype("1pcx", Val(:length)) == false
		@test LightSVG.istype("x1pc", Val(:length)) == false
	end
	@testset "string" begin
		@test LightSVG.istype("abcd", Val(:string))
		@test LightSVG.istype("", Val(:string))	# This passes, but should it?
		
		@test !LightSVG.istype(1, Val(:string))
		@test !LightSVG.istype(:none, Val(:string))
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
			@test LightSVG.istype(ratio, Val(:preserve_aspect_ratio))
		end
		suffixes = [" meet", " slice" ]
		for ratio in ratios
			for suffix in suffixes
				@test LightSVG.istype(string(ratio, suffix), Val(:preserve_aspect_ratio))
			end
		end
	end
	@testset "listofnumbers" begin
		# Should these be accepted? They don't convert correctly using string()
		@test LightSVG.istype([1], Val(:listofnumbers))
		@test LightSVG.istype([1, 1.1], Val(:listofnumbers))
		@test LightSVG.istype([1, 2, 3], Val(:listofnumbers))
		# Should (1, 2, 3) be accepted? They don't convert correctly using string()

		@test LightSVG.istype("1 2 3", Val(:listofnumbers))
		@test LightSVG.istype("1.1 2 3.3", Val(:listofnumbers))
		
		@test !LightSVG.istype("foo", Val(:listofnumbers))
		#@test !LightSVG.istype("1 2 foo", Val(:listofnumbers))
		#@test !LightSVG.istype("foo 2 3", Val(:listofnumbers))
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
