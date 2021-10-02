# Dispatch based on Val{}
# Originally called isa but this eclipsed base.isa when doing
# val isa Symbol

integer_regex = "[+-]?[0-9]+"

istype(::Integer, ::Val{:integer}) = true
istype(val, ::Val{:integer}) = contains(string(val), Regex("^$integer_regex\$"))

number_regex = "($integer_regex|[+-]?[0-9]*\\.[0-9]+([Ee]$integer_regex)?)"

istype(::Real, ::Val{:number}) = true
istype(val, ::Val{:number}) = contains(string(val), Regex("^$number_regex\$"))

istype(::Real, ::Val{:length}) = true
istype(val, ::Val{:length}) = contains(string(val), Regex("^($number_regex(em|ex|px|in|cm|mm|pt|pc|%)?)\$"))

istype(::AbstractString, ::Val{:string}) = true
istype(val, ::Val{:string}) = false

istype(val, ::Val{:preserve_aspect_ratio}) = contains(string(val), r"^(none|xMinYMin|xMidYMin|xMaxYMin|xMinYMid|xMidYMid|xMaxYMid|xMinYMax|xMidYMax|xMaxYMax)( meet| slice)?$")

istype(::AbstractVector{Real}, ::Val{:listofnumbers}) = true
istype(val, ::Val{:listofnumbers}) = contains(string(val), Regex(number_regex)) # TODO: This is weak

# TODO: This is weak
istype(val, ::Val{:languageid}) = istype(val, Val(:string))
istype(val, ::Val{:idstring}) = istype(val, Val(:string))
istype(val, ::Val{:stylestring}) = istype(val, Val(:string))
istype(val, ::Val{:iri}) = istype(val, Val(:string))

