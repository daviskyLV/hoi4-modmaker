extends Node

## HOI4 user's configuration location
var USER_DIR := "~/"
## Game's installation location
var GAME_DIR := "~/"
## Currently open mod folder, not counting the USER_DIR
var OPEN_MOD := "" 

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
