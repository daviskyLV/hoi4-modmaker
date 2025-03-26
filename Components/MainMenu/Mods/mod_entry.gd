extends PanelContainer
class_name ModlistEntry

const TAG = preload("res://Components/MainMenu/Mods/mod_entry_tag.tscn")

## Base mod descriptor in user's directory
var base_desc: Array[ScriptParser.ParsedAttribute] = []
## Mod descriptor in the actual mod's folder
var mod_desc: Array[ScriptParser.ParsedAttribute] = []

# Updates mod info based on the mod descriptor file path
func update_mod_descriptor(mod_descriptor_path: String) -> void:
	if !FileAccess.file_exists(mod_descriptor_path):
		return
	
	var base_file = FileAccess.open(mod_descriptor_path, FileAccess.READ)
	if !base_file:
		printerr("Couldn't open mod descriptor file! Path: "+mod_descriptor_path,
			FileAccess.get_open_error())
		return
	var base_content := base_file.get_as_text(true)
	base_file.close()
	
	# Parsing base descriptor file and extracting path variable from it
	base_desc = ScriptParser.parse_script(base_content)
	var path_attrs := ScriptParser.search_attribute(base_desc, "path", 1)
	if path_attrs.size() > 0:
		%Path.text = path_attrs[0].argument
		
	
	# Getting info about descriptor file within mod folder
	if !FileAccess.file_exists(path_attrs[0].argument+"/descriptor.mod"):
		return
	var mod_descriptor = FileAccess.open(path_attrs[0].argument+"/descriptor.mod", FileAccess.READ)
	if !mod_descriptor:
		printerr("Couldn't open mod descriptor file! Path: "+path_attrs[0].argument+"/descriptor.mod",
			FileAccess.get_open_error())
		return
	var mod_desc_content := mod_descriptor.get_as_text(true)
	mod_descriptor.close()
	
	mod_desc = ScriptParser.parse_script(mod_desc_content)
	var version_attrs := ScriptParser.search_attribute(mod_desc, "version", 1)
	if version_attrs.size() > 0:
		%ModVer.text = "Mod version: "+version_attrs[0].argument
	var game_ver_attrs := ScriptParser.search_attribute(mod_desc, "supported_version", 1)
	if game_ver_attrs.size() > 0:
		%GameVer.text = "Game version: "+game_ver_attrs[0].argument
	var name_attrs := ScriptParser.search_attribute(mod_desc, "name", 1)
	if name_attrs.size() > 0:
		%Title.text = name_attrs[0].argument
		
	# Clearing existing tags
	var tags = %TagsVBox.get_children()
	for n in tags:
		n.free()
	
	var tags_attrs := ScriptParser.search_attribute(mod_desc, "tags", 1)
	if tags_attrs.size() > 0:
		# Repopulating tags
		for t: ScriptParser.ParsedAttribute in tags_attrs[0].argument:
			var tag_instance = TAG.instantiate()
			tag_instance.text = t.attribute_name
			%TagsVBox.add_child(tag_instance)
		
	# Reading thumbnail
	if path_attrs.size() < 1:
		return
	
	var thumbnail_path = path_attrs[0].argument+"/"
	var picture_attrs := ScriptParser.search_attribute(mod_desc, "picture", 1)
	if picture_attrs.size() > 0:
		thumbnail_path += picture_attrs[0].argument
	
	if FileAccess.file_exists(thumbnail_path):
		pass
	elif FileAccess.file_exists(path_attrs[0].argument+"/thumbnail.png"):
		thumbnail_path = path_attrs[0].argument+"/thumbnail.png"
	elif FileAccess.file_exists(path_attrs[0].argument+"/thumbnail.jpg"):
		thumbnail_path = path_attrs[0].argument+"/thumbnail.jpg"
	else:
		%Thumbnail.texture = ImageTexture.new()
		return
	
	# Setting thumbnail image
	var thumb_image := Image.load_from_file(thumbnail_path)
	var thumb_texture = ImageTexture.create_from_image(thumb_image)
	%Thumbnail.texture = thumb_texture
