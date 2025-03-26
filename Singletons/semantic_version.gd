extends Node

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
