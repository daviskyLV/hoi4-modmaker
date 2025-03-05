extends Node

var USER_DIR := "~/" ## HOI4 user's configuration location
var GAME_DIR := "~/" ## Game's installation location

func _init() -> void:
	var os = OS.get_name()
	if os == "Windows":
		USER_DIR = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Paradox Interactive/Hearts of Iron IV/"
		GAME_DIR = "C:/Program Files (x86)/Steam/steamapps/common/Hearts of Iron IV/"
	elif os == "macOS":
		USER_DIR = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)+"/Paradox Interactive/Hearts of Iron IV/"
		GAME_DIR = "~/"
	else:
		USER_DIR = "~/.local/share/Paradox Interactive/Hearts of Iron IV/"
		GAME_DIR = "~/"

## Parse mod descriptor's contents and return a dictionary of keys with values as array
## Returned example: {name: ["my mod"], tags: ["hello", "world!"]}
func parse_mod_descriptor(content: String) -> Dictionary:
	var parsed: Dictionary = {}
	var lines := content.split("\n")
	
	var curkey := ""
	var curkey_opening := ""
	for line in lines:
		var stripped_line = line.strip_edges()
		if !curkey_opening.is_empty():
			# The current key already has an opening
			if (curkey_opening == '"' and stripped_line == '"') or \
				(curkey_opening == "{" and stripped_line == "}"):
				# Current key is closed
				curkey_opening = ""
				curkey = ""
				continue
			
			# Adds a new value to the key
			parsed[curkey].append(stripped_line.trim_prefix('"').trim_suffix('"'))
			continue
			
		# New line without opening, assuming new key
		var assign_start := stripped_line.find('="') # Finding assignment
		if assign_start == -1:
			assign_start = stripped_line.find("={")
		if assign_start == 0:
			printerr("Mod descriptor value found without key! Line:|"+line+"|")
			continue
		elif assign_start == -1:
			printerr("Mod descriptor has no valid definition for value! Line:|"+line+"|")
			continue
		
		curkey = stripped_line.substr(0,assign_start)
		if !parsed.has(curkey):
			parsed[curkey] = PackedStringArray([])
			
		var opening_char = stripped_line.substr(assign_start+1,1)
		if stripped_line.length() == assign_start+2:
			# Key definition only opens, doesn't close
			curkey_opening = opening_char
			continue
			
		var val = stripped_line.substr(assign_start+2)
		if stripped_line.ends_with('"') and opening_char == '"':
			val = val.trim_suffix('"')
		elif stripped_line.ends_with("}") and opening_char == "{":
			val = val.trim_suffix('}')
		else:
			curkey_opening = stripped_line.substr(assign_start+1)
		
		parsed[curkey].append(val)
	
	return parsed

## Validate inputted path and convert it automatically to Unix style
func validate_path(path: String, simplify: bool = true) -> String:
	# Removing invalid characters
	if OS.get_name() == "Windows":
		path = path.replace("?","")
		path = path.replace("*","")
		path = path.replace('"',"")
		path = path.replace("|","")
		path = path.replace("<","")
		path = path.replace(">","")
	path = path.replace("\\","/")
	
	if path.is_empty():
		return ""
	
	# Removing additional : characters
	var first_cchar := path.find(":")
	if first_cchar != -1 and first_cchar < path.length()-1:
		# A : character exists and there are more characters after it
		var prefix := path.substr(0, first_cchar+1)
		var rest := path.substr(first_cchar+1).replace(":", "")
		path = prefix+rest
	
	if simplify:
		var simplified_path := path.simplify_path()
		if path.ends_with("/"):
			simplified_path += "/" # Keeping the last / for convenience
		path = simplified_path
	
	return path

## Parse a semantic version string and return the version as string array
## Returned example: ["Major", "Minor", "Patch", "Additional"]
func parse_semver(version: String) -> Array[String]:
	var splitted := version.strip_edges().split(".", false)
	for i in range(splitted.size(), 3):
		splitted.append("0") # Append missing semver
	
	return splitted

## Check whether a semantic version passes the required semantic version
## Also allows the required version to have ranges, eg. >=ver, <ver, ~ver, ^ver, 1.*.0
func passes_semver(version: String, required: String) -> bool:
	var ver_semver := parse_semver(version)
	var req_semver := parse_semver(required)
	### TODO: Finish semver checks https://github.com/npm/node-semver
	
	return true
