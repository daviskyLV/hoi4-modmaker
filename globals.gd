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
