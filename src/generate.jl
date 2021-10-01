include("./validators.jl")

using LightDOM

struct Attribute
	name::Symbol
	validator::Symbol
	default::Any

	Attribute(name::Symbol, validator::Symbol) = new(name, validator, :none)
	Attribute(name::Symbol, validator::Symbol, default) = new(name, validator, default)
end

global_attributes = Dict(
:core => [
	Attribute(:id, :string),
	Attribute(:lang, :languageid),
	Attribute(:tabindex, :integer),
	Attribute(Symbol("xml:base"), :iri),
	Attribute(Symbol("xml:lang"), :languageid)
],
:styling => [
	Attribute(:class, :idstring),
	Attribute(:style, :stylestring)
],
:presentation => [
	# TODO: Proper validators
	Attribute(Symbol("alignment-baseline"), :string, :auto),
	Attribute(Symbol("baseline-shift"), :string, :auto),
	Attribute(Symbol("clip-path"), :string),
	Attribute(Symbol("clip-rule"), :string, "nonezero"),
	Attribute(:color, :string),
	Attribute(Symbol("color-interpolation"), :string, "sRGB"),
	Attribute(Symbol("color-interpolation-filters"), :string, "linearRGB"),
	Attribute(Symbol("color-rendering"), :string, :auto),
	Attribute(:cursor, :string),
	Attribute(:d, :string),
	Attribute(:direction, :string, "ltr"),
	Attribute(:display, :string),
	Attribute(Symbol("dominant-baseline"), :string),
	Attribute(:fill, :string),
	Attribute(Symbol("fill-opacity"), :string),
	Attribute(Symbol("fill-rule"), :string, "nonzero"),
	Attribute(:filter, :string, :none),
	Attribute(Symbol("flood-color"), :string),
	Attribute(Symbol("flood-opacity"), :string),
	Attribute(Symbol("font-family"), :string),
	Attribute(Symbol("font-size"), :string),
	Attribute(Symbol("font-size-adjust"), :string),
	Attribute(Symbol("font-stretch"), :string),
	Attribute(Symbol("font-style"), :string),
	Attribute(Symbol("font-variant"), :string),
	Attribute(Symbol("font-weight"), :string, :normal),
	Attribute(Symbol("image-rendering"), :string, :auto),
	Attribute(Symbol("letter-spacing"), :string, :normal),
	Attribute(Symbol("lighting-color"), :string),
	Attribute(Symbol("marker-end"), :string, :none),
	Attribute(Symbol("marker-mid"), :string, :none),
	Attribute(Symbol("marker-start"), :string, :none),
	Attribute(:mask, :string),
	Attribute(:opacity, :number),
	Attribute(:overflow, :string, "visible"),
	Attribute(Symbol("pointer-events"), :string, "visiblePainted"),
	Attribute(Symbol("shape-rendering"), :string),
	Attribute(Symbol("solid-color"), :string),
	Attribute(Symbol("solid-opacity"), :string),
	Attribute(Symbol("stop-color"), :string),
	Attribute(Symbol("stop-opacity"), :string),
	Attribute(:stroke, :string),
	Attribute(Symbol("stroke-dasharray"), :string),
	Attribute(Symbol("stroke-dashoffset"), :string),
	Attribute(Symbol("stroke-linecap"), :string, "butt"),
	Attribute(Symbol("stroke-linejoin"), :string, "miter"),
	Attribute(Symbol("stroke-miterlimit"), :string),
	Attribute(Symbol("stroke-opacity"), :string),
	Attribute(Symbol("stroke-width"), :string),
	Attribute(Symbol("text-anchor"), :string, :inherit),
	Attribute(Symbol("text-decoration"), :string, :inherit),
	Attribute(Symbol("text-rendering"), :string, :auto),
	Attribute(:transform, :string),
	Attribute(Symbol("unicode-bidi"), :string),
	Attribute(Symbol("vector-effect"), :string),
	Attribute(:visibility, :string, :visible),
	Attribute(Symbol("word-spacing"), :length, :inherit),
	Attribute(Symbol("writing-mode"), :string, "lr-tb")
],
:aria => [
]
)

function setprop!(props, name, value, validator)
	validator_symbol = Symbol(string("is", validator))
	eval(validator_symbol)(value) || error(string(name, " must be ", validator))
	props[name] = value
end
function setprop!(props, name, value, default, validator)
	if value != default
		setprop!(props, name, value, validator)
	end
end

macro generate(def)
	def.head == :call || error()
	func_name = def.args[1]
	tag = Meta.quot(Symbol(lowercase(string(func_name))))
	
	# Convert Expr's into Attributes to simplify all the codegen parsing later
	attrs = []
	for prop in def.args[2:end]
		prop isa Symbol && error("validator required")

		if prop isa Expr 
			if prop.head === :...
				# Replace any expansion sets with the appropriates global attributes
				attr = get(global_attributes, prop.args[1], Nothing)
				if attr !== Nothing
					append!(attrs, attr)
				end
			elseif prop.head === :kw
				name = prop.args[1]
				if prop.args[2] isa Expr
					# dump(prop.args[2])
					# A default has been specified, parsed as |(default, validator)
					default = prop.args[2].args[2]
					validator = prop.args[2].args[3]
				else
					default = Nothing
					validator = prop.args[2]
				end
				attr = Attribute(name, validator, default)
				push!(attrs, attr)
			end
		else
			error("Unknown prop")
		end

		
	end

	prop_defs = map(attrs) do attr
		default = attr.default
		if default === Nothing
			return attr.name
		end
		# Symbols should be treated as quoted symbols, except for Nothing
		if default isa Symbol && default !== :Nothing
			default = Meta.quot(default)
		end
		Expr(:kw, attr.name, default)
	end

	validators = map(attrs) do attr
		prop_name = attr.name
		validator = attr.validator
		default = attr.default

		validator_quot = Meta.quot(validator)

		if default === Nothing
			:(setprop!(props, $(Meta.quot(prop_name)), $prop_name, $validator_quot))
		else
			# Symbols should be treated as quoted symbols, except for Nothing
			if default isa Symbol && default !== :Nothing
				default = Meta.quot(default)
			end
			:(setprop!(props, $(Meta.quot(prop_name)), $prop_name, $default, $validator_quot))
		end
	end

	func = quote
	function $func_name(;$(prop_defs...))
		props = Dict()
		$(validators...)
		Element($tag; props...)
	end
	export $func_name
	end
	show(func)
	eval(func)
end


