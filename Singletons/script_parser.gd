extends Node

## Logical operator linking attribute to it's value, NONE if only name is specified
enum ATTRIBUTE_OPERATOR {EQUAL, GREATER_THAN, LESS_THAN, NONE}
## How the attribute should be "glued together" with the previous attribute.
enum ATTRIBUTE_LINE {SAME_LINE, NEWLINE, DOUBLE_NEWLINE}

## Parsed <attribute> = <argument> key-value combination.
## Some attributes don't have an explicit value definition (eg. comments or numbers)
class ParsedAttribute:
	## Logical operator linking attribute to it's value, NONE if only name is specified
	var operator: ATTRIBUTE_OPERATOR
	## Attribute name, if it starts with # then acts as comment
	var attribute_name: String
	## Argument that is linked to attribute via a logical operator.
	## Can be of type [String] or [ParsedAttribute] array for nesting
	var argument: Variant
	## How the attribute should be "glued together" with the previous attribute when converting to string.
	var line_glue: ATTRIBUTE_LINE

	func _init(attribute: String, arg: Variant, op: ATTRIBUTE_OPERATOR, glue: ATTRIBUTE_LINE) -> void:
		operator = op
		attribute_name = attribute
		argument = arg
		line_glue = glue
	
	## Parses attribute's glue into string
	func stringify_glue() -> String:
		var beginning: String = ""
		if line_glue == ATTRIBUTE_LINE.SAME_LINE:
			beginning = " "
		elif line_glue == ATTRIBUTE_LINE.NEWLINE:
			beginning = "\n"
		elif line_glue == ATTRIBUTE_LINE.DOUBLE_NEWLINE:
			beginning = "\n\n"
		return beginning
	
	func _to_string() -> String:
		if attribute_name.begins_with("#"):
			return attribute_name
			
		var an := attribute_name
		if an.contains(" ") or an.contains("\t") or an.contains('"') or \
		an.contains("{") or an.contains("}") or an.contains("\\"):
			an = '"' + attribute_name + '"'
		
		if operator == ATTRIBUTE_OPERATOR.NONE:
			return an
		
		var attr_s := an
		if operator == ATTRIBUTE_OPERATOR.EQUAL:
			attr_s += " = "
		elif operator == ATTRIBUTE_OPERATOR.GREATER_THAN:
			attr_s += " > "
		else:
			attr_s += " < "
		
		if argument is String:
			var argn: String = argument
			if argn.contains(" ") or argn.contains("\t") or argn.contains('"') or \
			argn.contains("{") or argn.contains("}") or argn.contains("\\"):
				argn = '"' + argument + '"'
			
			return attr_s + argn
			
		# ParsedAttribute type
		attr_s += "{\n"
		# Listing argument list
		var ina_s := ""
		for arg: ParsedAttribute in argument:
			ina_s += arg.stringify_glue() + arg.to_string()
		ina_s = ina_s.indent("\t")
		
		attr_s += ina_s + "\n}"
		return attr_s

## Used when parsing HOI4 scripts
class ScriptParsing:
	## Code to parse
	var code: String
	## Current character index that is being parsed
	var _current_index: int
	## Parsed data represented as attribute array
	var parsed_data: Array[ParsedAttribute]
	
	## Convert previous attribute terminator to attribute line type
	func convert_terminator(terminator: String) -> ATTRIBUTE_LINE:
		if terminator.contains("\n\n"):
			return ATTRIBUTE_LINE.DOUBLE_NEWLINE
		elif terminator.contains("\n"):
			return ATTRIBUTE_LINE.NEWLINE
		return ATTRIBUTE_LINE.SAME_LINE
	
	## Parse a block of code from a HOI4 script. Current character should be after block opening.
	## Returns an array of parsed attributes
	func parse_block() -> Array[ParsedAttribute]:
		var parsed: Array[ParsedAttribute] = []
		var clen := code.length() # for optimization
		
		## Current attribute name
		var cur_attrib: String = ""
		var cur_op: ATTRIBUTE_OPERATOR = ATTRIBUTE_OPERATOR.NONE
		## Current parsed argument value represented as string
		var cur_arg: String = ""
		var block_open: bool = true
		## String definition using " is open
		var str_open: bool = false
		## Whether attribute has been defined and we are parsing operator/argument
		var attrib_defined: bool = false
		var prev_terminator: String = ""
		
		## Flag when set to true resets attribute definition on next iteration
		var reset_attrib: bool = false
		
		while block_open and _current_index < clen:
			# Resetting attribute definition if flag set
			if reset_attrib:
				cur_attrib = ""
				cur_op = ATTRIBUTE_OPERATOR.NONE
				cur_arg = ""
				str_open = false
				attrib_defined = false
				reset_attrib = false
			
			var cur_char: String = code.substr(_current_index, 1)
			_current_index += 1
			
			# Checking if current character is a whitespace and attribute is undefined
			if cur_char.strip_edges().is_empty() and cur_attrib.is_empty():
				# attribute not in progress, skipping whitespace
				prev_terminator += cur_char
				continue
			
			# checking if it's a continuation of a comment
			if cur_attrib.begins_with("#"):
				# currently parsing a comment
				if cur_char == "\n":
					# newline, ending comment
					parsed.append(ParsedAttribute.new(
						cur_attrib, "", ATTRIBUTE_OPERATOR.NONE,
						convert_terminator(prev_terminator)
					))
					prev_terminator = "\n"
					reset_attrib = true
				else:
					# comment already defined, adding content
					cur_attrib += cur_char
				continue
			
			# escaping next character within string
			if str_open and cur_char == "\\":
				var next_char := code.substr(_current_index, 1)
				_current_index += 1
				if not attrib_defined:
					cur_attrib += next_char
				else:
					cur_arg += next_char
				continue
			
			# Handling opening/closing of strings
			if cur_char == '"':
				if str_open:
					# Closing string
					if not attrib_defined:
						# Closing attribute string
						attrib_defined = true
						str_open = false
					else:
						# Closing argument string and finishing the parsed attribute
						parsed.append(ParsedAttribute.new(
							cur_attrib, cur_arg, cur_op, convert_terminator(prev_terminator)
						))
						prev_terminator = ""
						reset_attrib = true
				else:
					if attrib_defined and cur_op == ATTRIBUTE_OPERATOR.NONE:
						# Inserting previous attribute name as key:value pair
						parsed.append(ParsedAttribute.new(
							cur_attrib, cur_arg, cur_op, convert_terminator(prev_terminator)
						))
						prev_terminator = ""
						attrib_defined = false
						cur_attrib = ""
						cur_arg = ""
						
					# Opening string
					str_open = true
				continue
			
			# checking if it's a start of a comment
			if cur_char == '#':
				if not cur_attrib.is_empty():
					# attribute:argument combo previously defined, ending it
					parsed.append(ParsedAttribute.new(
						cur_attrib, cur_arg, cur_op, convert_terminator(prev_terminator)
					))
					prev_terminator = ""
					reset_attrib = true
				
				# Starting a new comment attribute
				cur_attrib = cur_char
				continue
			
			# Checking if content is within a string
			if str_open:
				if cur_char == "\n":
					# newline terminating string
					if not attrib_defined:
						# Closing attribute string
						attrib_defined = true
						str_open = false
					else:
						# Closing argument string and finishing the parsed attribute
						parsed.append(ParsedAttribute.new(
							cur_attrib, cur_arg, cur_op, convert_terminator(prev_terminator)
						))
						prev_terminator = "\n"
						reset_attrib = true
					continue
				
				# Adding characters to the string
				if attrib_defined:
					cur_arg += cur_char
				else:
					cur_attrib += cur_char
				continue
			
			# Setting operator
			if cur_char == "=":
				cur_op = ATTRIBUTE_OPERATOR.EQUAL
				attrib_defined = true
				continue
			elif cur_char == ">":
				cur_op = ATTRIBUTE_OPERATOR.GREATER_THAN
				attrib_defined = true
				continue
			elif cur_char == "<":
				cur_op = ATTRIBUTE_OPERATOR.LESS_THAN
				attrib_defined = true
				continue
			
			# Whitespace check for non empty attribute
			if cur_char.strip_edges().is_empty():
				if not attrib_defined:
					# finished defining attribute
					attrib_defined = true
				else:
					if cur_op != ATTRIBUTE_OPERATOR.NONE and not cur_arg.is_empty():
						# Operator defined and argument set, appending argument to list
						parsed.append(ParsedAttribute.new(
							cur_attrib, cur_arg, cur_op, convert_terminator(prev_terminator)
						))
						prev_terminator = cur_char
						reset_attrib = true
					else:
						# Operator not defined yet, ignore for now
						pass
				continue
			
			# Checking for block closing
			if cur_char == "}":
				block_open = false
				continue
			elif cur_char == "{":
				# parsing inner block
				var inner_block := parse_block()
				# Appending inner block
				parsed.append(ParsedAttribute.new(
					cur_attrib, inner_block, cur_op, convert_terminator(prev_terminator)
				))
				prev_terminator = ""
				reset_attrib = true
				continue
			
			# Remaining characters act same as opened string
			if not attrib_defined:
				cur_attrib += cur_char
			else:
				cur_arg += cur_char
			
		# Resetting attribute definition if flag set
		if reset_attrib:
			cur_attrib = ""
			cur_op = ATTRIBUTE_OPERATOR.NONE
			cur_arg = ""
			str_open = false
			attrib_defined = false
			reset_attrib = false
		
		# Adding leftover definitions, if they exist
		if not cur_attrib.is_empty():
			parsed.append(ParsedAttribute.new(
				cur_attrib, cur_arg, cur_op, convert_terminator(prev_terminator)
			))
			prev_terminator = ""
		
		return parsed
	
	func _init(code: String):
		code = code.replace("\r", "")
		self.code = code
		_current_index = 0
		parsed_data = parse_block()
	
	func _to_string() -> String:
		var ret: String = ""
		for attribute: ParsedAttribute in parsed_data:
			ret += attribute.to_string() + "\n"
		
		return ret
		
## Parse a HOI4 script into an array of parsed attributes.
## [param code] should be the entire script's contents
func parse_script(code: String) -> Array[ParsedAttribute]:
	var parsed := ScriptParsing.new(code)
	return parsed.parsed_data

## Filter an attribute list by attribute name.
## [param arr] - the [ParsedAttribute] array to search in.
## [param target] - the attribute to search.
## [param limit] - limit the amount of attributes returned, -1 for unlimited
func search_attribute(
	arr: Array[ParsedAttribute],
	target: String,
	limit: int = -1
) -> Array[ParsedAttribute]:
	var found: Array[ParsedAttribute] = []
	for attr: ParsedAttribute in arr:
		if attr.attribute_name == target:
			found.append(attr)
			if limit > 0 and found.size() >= limit:
				return found
	
	return found
