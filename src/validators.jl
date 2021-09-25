integer_regex = "[+-]?[0-9]+"

isinteger(::Integer) = true
isinteger(val) = contains(string(val), Regex("^$integer_regex\$"))

number_regex = "($integer_regex|[+-]?[0-9]*\\.[0-9]+([Ee]$integer_regex)?)"

isnumber(::Real) = true
isnumber(val) = contains(string(val), Regex("^$number_regex\$"))

islength(::Real) = true
islength(val) = contains(string(val), Regex("^($number_regex(em|ex|px|in|cm|mm|pt|pc|%)?)\$"))

isstring(::AbstractString) = true
isstring(val) = false

ispreserve_aspect_ratio(val) = contains(string(val), r"^(none|xMinYMin|xMidYMin|xMaxYMin|xMinYMid|xMidYMid|xMaxYMid|xMinYMax|xMidYMax|xMaxYMax)( meet| slice)?$")

islistofnumbers(::AbstractVector{Real}) = true
islistofnumbers(val) = contains(string(val), Regex(number_regex)) # TODO: This is weak

# TODO: This is weak
islanguageid(val) = isstring(val)
isidstring(val) = isstring(val)
isstylestring(val) = isstring(val)
isiri(val) = isstring(val)
