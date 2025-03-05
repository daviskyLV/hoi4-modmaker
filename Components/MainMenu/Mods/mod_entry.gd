extends PanelContainer
class_name ModlistEntry

const TAG = preload("res://Components/MainMenu/Mods/mod_entry_tag.tscn")

var _mod_info := {
	mod_name = "",
	game_version = "",
	mod_version = "",
	path = "",
	tags = [],
	thumbnail = ImageTexture.new()
}

func get_mod_info() -> Dictionary:
	return _mod_info.duplicate(true)

# Updates mod info based on the mod descriptor file path
func update_mod_descriptor(mod_descriptor_path: String) -> void:
	if !FileAccess.file_exists(mod_descriptor_path):
		return
	
	var base_file = FileAccess.open(mod_descriptor_path, FileAccess.READ)
	if !base_file:
		printerr("Couldn't open mod descriptor file! Path: "+mod_descriptor_path,
			FileAccess.get_open_error())
		return
	var base_content := base_file.get_as_text()
	base_file.close()
	
	var parsed_base_descriptor := Globals.parse_mod_descriptor(base_content)
	if parsed_base_descriptor.has("path"):
		_mod_info.path = parsed_base_descriptor.path[0]
		%Path.text = _mod_info.path
	
	# Getting info about descriptor file within mod folder
	if !FileAccess.file_exists(_mod_info.path+"/descriptor.mod"):
		return
	var mod_descriptor = FileAccess.open(_mod_info.path+"/descriptor.mod", FileAccess.READ)
	if !mod_descriptor:
		printerr("Couldn't open mod descriptor file! Path: "+_mod_info.path+"/descriptor.mod",
			FileAccess.get_open_error())
		return
	var mod_desc_content := mod_descriptor.get_as_text()
	mod_descriptor.close()
	
	var parsed_mod_desc := Globals.parse_mod_descriptor(mod_desc_content)
	if parsed_mod_desc.has("version"):
		_mod_info.mod_version = parsed_mod_desc.version[0]
		%ModVer.text = "Mod version: "+_mod_info.mod_version
	if parsed_mod_desc.has("supported_version"):
		_mod_info.game_version = parsed_mod_desc.supported_version[0]
		%GameVer.text = "Game version: "+_mod_info.game_version
	if parsed_mod_desc.has("name"):
		_mod_info.mod_name = parsed_mod_desc.name[0]
		%Title.text = _mod_info.mod_name
	if parsed_mod_desc.has("tags"):
		_mod_info.tags = Array(parsed_mod_desc.tags)
	
	# Clearing existing tags
	var tags = %TagsVBox.get_children()
	for n in tags:
		n.free()
	# Repopulating tags
	for t in _mod_info.tags:
		var tag_instance = TAG.instantiate()
		tag_instance.text = t
		%TagsVBox.add_child(tag_instance)
		
	# Reading thumbnail
	var thumbnail_path = _mod_info.path+"/"
	if parsed_mod_desc.has("picture"):
		thumbnail_path += parsed_mod_desc.picture[0]
	
	if FileAccess.file_exists(thumbnail_path):
		pass
	elif FileAccess.file_exists(_mod_info.path+"/thumbnail.png"):
		thumbnail_path = _mod_info.path+"/thumbnail.png"
	elif FileAccess.file_exists(_mod_info.path+"/thumbnail.jpg"):
		thumbnail_path = _mod_info.path+"/thumbnail.jpg"
	else:
		_mod_info.thumbnail = ImageTexture.new()
		%Thumbnail.texture = _mod_info.thumbnail
		return
	
	# Setting thumbnail image
	var thumb_image := Image.load_from_file(thumbnail_path)
	var thumb_texture = ImageTexture.create_from_image(thumb_image)
	_mod_info.thumbnail = thumb_texture
	%Thumbnail.texture = _mod_info.thumbnail
