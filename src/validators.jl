# Dispatch based on Val{}
# Originally called isa but this eclipsed base.isa when doing
# val isa Symbol

# Convenience allowing passing the symbol without calling Val everywhere
istype(val, symbol::Symbol) = istype(val, Val(symbol))

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

istype(::AbstractVector{T}, ::Val{:listofnumbers}) where {T<:Real} = true
istype(vals::Union{AbstractVector,Tuple}, ::Val{:listofnumbers}) = all(val -> istype(val, :number), vals)
function istype(val, ::Val{:listofnumbers})
	vals = split(string(val), ' ')
	all(val -> istype(val, :number), vals)
end

# TODO: This is weak
istype(val, ::Val{:languageid}) = istype(val, :string)
istype(val, ::Val{:idstring}) = istype(val, :string)
istype(val, ::Val{:stylestring}) = istype(val, :string)
istype(val, ::Val{:iri}) = istype(val, :string)


# Generic no-op property formatting
toprop(val, ::Val) = val
# Convenience allowing passing the symbol without calling Val everywhere
toprop(val, symbol::Symbol) = toprop(val, Val(symbol))

function toprop(vals::Union{AbstractVector,Tuple}, ::Val{:listofnumbers})
	join(
		map(val -> toprop(val, :number), vals),
		' '
	)
end
