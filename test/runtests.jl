using Test
using LightDOM
using LightSVG

@testset "validators" begin
	@testset "isinteger" begin
		# Valid Values
		@test LightSVG.isinteger(1)
		@test LightSVG.isinteger("1")
		@test LightSVG.isinteger("-1")
		@test LightSVG.isinteger("00000000000")
		# Invalid values
		@test !LightSVG.isinteger(1.1)
		@test !LightSVG.isinteger("1.1")
		@test !LightSVG.isinteger("foo")
		@test !LightSVG.isinteger("")
	end
	@testset "isnumber" begin
		# Valid values
		@test LightSVG.isnumber(1)
		@test LightSVG.isnumber("1")
		@test LightSVG.isnumber("0.1")
		@test LightSVG.isnumber("0.1e1")
		@test LightSVG.isnumber(".1e1")

		# Invalid
		@test !LightSVG.islength(1+2im)
		@test !LightSVG.islength("1e1")	# Invalid exponent format
		@test !LightSVG.islength("1.e1") # Invalid exponent format
		@test !LightSVG.islength("foobar")
		@test !LightSVG.islength("x1")
		@test !LightSVG.islength("1x")
	end
	@testset "islength" begin
		# Valid values
		@test LightSVG.islength(1)
		@test LightSVG.islength("1")
		@test LightSVG.islength("0.1")
		@test LightSVG.islength("0.1e1")
		@test LightSVG.islength(".1e1")
		@test LightSVG.islength("1em")
		@test LightSVG.islength("1ex")
		@test LightSVG.islength("1px")
		@test LightSVG.islength("1in")
		@test LightSVG.islength("1cm")
		@test LightSVG.islength("1mm")
		@test LightSVG.islength("1pt")
		@test LightSVG.islength("1pc")
		@test LightSVG.islength("1%")
		# Invalid
		@test LightSVG.islength(1+2im) == false
		@test LightSVG.islength("1e1") == false	# Invalid exponent format
		@test LightSVG.islength("1.e1") == false	# Invalid exponent format
		@test LightSVG.islength("foobar") == false
		@test LightSVG.islength("x1") == false
		@test LightSVG.islength("1x") == false
		@test LightSVG.islength("1pcx") == false
		@test LightSVG.islength("x1pc") == false
	end
	@testset "isstring" begin
		@test LightSVG.isstring("abcd")
		@test LightSVG.isstring("")	# This passes, but should it?
		
		@test !LightSVG.isstring(1)
		@test !LightSVG.isstring(:none)
	end
	@testset "ispreserve_aspect_ratio" begin
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
			@test LightSVG.ispreserve_aspect_ratio(ratio)
		end
		suffixes = [" meet", " slice" ]
		for ratio in ratios
			for suffix in suffixes
				@test LightSVG.ispreserve_aspect_ratio(string(ratio, suffix))
			end
		end
	end
	@testset "islistofnumbers" begin
		# Should these be accepted? They don't convert correctly using string()
		@test LightSVG.islistofnumbers([1])
		@test LightSVG.islistofnumbers([1, 1.1])
		@test LightSVG.islistofnumbers([1, 2, 3])
		# Should (1, 2, 3) be accepted? They don't convert correctly using string()

		@test LightSVG.islistofnumbers("1 2 3")
		@test LightSVG.islistofnumbers("1.1 2 3.3")
		
		@test !LightSVG.islistofnumbers("foo")
		@test !LightSVG.islistofnumbers("1 2 foo")
		@test !LightSVG.islistofnumbers("foo 2 3")
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
		@test_throws SVG(id=1)	#id must be string
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
