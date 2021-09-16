module LightSVG

include("./generate.jl")

@macroexpand @generate SVG(
	height=auto|length,
	width=auto|length,
	preserveAspectRatio="xMidYMid meet"|preserve_aspect_ratio,
	viewBox=Nothing|listofnumbers,
	x=0|length,
	y=0|length,
	core...,
	styling...,
	presentation...,
	aria...
)

end # module
