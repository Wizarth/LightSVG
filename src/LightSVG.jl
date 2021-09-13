module LightSVG

using LightDOM

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

macro generate(def)
	def.head == :call || error()
	func_name = def.args[1]
	tag = Meta.quot(Symbol(lowercase(string(func_name))))
	
	props = def.args[2:end]
	# TODO: Replace any expansion sets with the appropriates
	props = filter(props) do prop
		prop.head !== :...
	end

	prop_defs = map(props) do prop
		prop isa Symbol && error("validator required")

		prop.head == :kw || error()

		prop_name = prop.args[1]
		# prop.args 
		if prop.args[2] isa Expr
			# A default has been specified, parsed as |(default, validator)
			prop.args[2].head == :call || error()
			prop.args[2].args[1] == :| || error()
			default = prop.args[2].args[2]
			# If it's a symbol, put it back in as a quoted symbol. This is a convenience
			if default isa Symbol
				default = Meta.quot(default)
			end
			return Expr(:kw, prop_name, default)
		end
		# We don't care about validators here
		
		return prop_name
	end
	validators = map(props) do prop
		prop_name = prop.args[1]
		validator = Nothing
		default = Nothing
		if prop.args[2] isa Expr
			dump(prop.args[2])
			# A default has been specified, parsed as |(default, validator)
			default = prop.args[2].args[2]
			if default isa Symbol
				default = Meta.quot(default)
			end
			validator = prop.args[2].args[3]
		else
			validator = prop.args[2]
		end
		validator_symbol = Symbol(string("is", validator))
		validator_expr = :($validator_symbol($prop_name))

		validate_set = quote 
			$validator_expr || error()
			props[$(Meta.quot(prop_name))] = $prop_name
		end

		# Don't validate, thus don't insert into props, if it's the default
		if default != Nothing
			validate_set = quote
			if $prop_name != $default
				$validate_set
			end
			end
		end
		validate_set
	end

	func = quote
	function $func_name(;$(prop_defs...))
		props = Dict()
		$(validators...)
		Element($tag; props...)
	end
	end
	show(func)
	eval(func)
end


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

export SVG

end # module