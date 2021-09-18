using Test
using LightDOM
using LightSVG

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
