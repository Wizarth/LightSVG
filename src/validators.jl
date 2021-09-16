integer_regex = "[+-]?[0-9]+"
number_regex = "($integer_regex|[+-]?[0-9]*\\.[0-9]+([Ee]$integer_regex)?)"

function islength(val)
	val isa Real && return true
	contains(string(val), Regex("^($number_regex(em|ex|px|in|cm|mm|pt|pc|%)?)\$"))
end

isstring(val) = val isa AbstractString

ispreserve_aspect_ratio(val) = contains(string(val), r"^(none|xMinYMin|xMidYMin|xMaxYMin|xMinYMid|xMidYMid|xMaxYMid|xMinYMax|xMidYMax|xMaxYMax) (meet|slice)?$")

function islistofnumbers(val)
	val isa AbstractVector{Real} && return true
	contains(string(val), Regex(number_regex)) # TODO: This is weak
end


