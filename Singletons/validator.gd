extends Node

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
