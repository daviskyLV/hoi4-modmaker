extends Window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	force_native = true
	
	_on_thumbnail_path_text_changed(%ThumbnailPath.text)
	
	show()

func _recheck_conditions() -> void:
	if %NameInput.text.strip_edges().length() < 3:
		%Create.disabled = true
		return
		
	if %PathInput.text.strip_edges().trim_prefix("mod/").is_empty():
		%Create.disabled = true
		return
		
	# Counting tags
	var tags_enabled := 0
	if %AltHistInput.button_pressed:
		tags_enabled += 1
	if %BalanceInput.button_pressed:
		tags_enabled += 1
	if %EventsInput.button_pressed:
		tags_enabled += 1
	if %FixesInput.button_pressed:
		tags_enabled += 1
	if %GameplayInput.button_pressed:
		tags_enabled += 1
	if %GraphicsInput.button_pressed:
		tags_enabled += 1
	if %HistoricalInput.button_pressed:
		tags_enabled += 1
	if %IdeologiesInput.button_pressed:
		tags_enabled += 1
	if %MapInput.button_pressed:
		tags_enabled += 1
	if %MilitaryInput.button_pressed:
		tags_enabled += 1
	if %NatFocInput.button_pressed:
		tags_enabled += 1
	if %SoundInput.button_pressed:
		tags_enabled += 1
	if %TechnologiesInput.button_pressed:
		tags_enabled += 1
	if %TranslationInput.button_pressed:
		tags_enabled += 1
	if %UtilitiesInput.button_pressed:
		tags_enabled += 1
	
	if tags_enabled > 10 or tags_enabled < 1:
		%Create.disabled = true
		return
		
	# Checking version strings
	## TODO: verify correct format for game version
	if %GameVerInput.text.strip_edges().length() < 1:
		%Create.disabled = true
		return
	if %ModVerInput.text.strip_edges().length() < 1:
		%Create.disabled = true
		return
	
	%Create.disabled = false

func _tag_toggled(_toggled_on: bool) -> void:
	_recheck_conditions()

func _on_close_requested() -> void:
	hide()
	queue_free()


func _on_thumbnail_path_text_changed(new_text: String) -> void:
	var validated_path = Globals.validate_path(new_text)
	# Setting thumbnail image
	var thumb_image := Image.load_from_file(validated_path)
	var thumb_texture = ImageTexture.create_from_image(thumb_image)
	%Thumbnail.texture = thumb_texture


func _on_path_input_text_validated(_validated_text: String) -> void:
	_recheck_conditions()

var error_displayed := false
func _display_error(err: Error):
	error_displayed = true
	var prev_text: String = %Create.text
	%Create.text = "ERROR: "+error_string(err)
	await get_tree().create_timer(5).timeout
	%Create.text = prev_text
	error_displayed = false

func _on_create_pressed() -> void:
	if error_displayed:
		return
	
	var descriptor: Array[Parser.ParsedAttribute] = []
	descriptor.append(
		Parser.ParsedAttribute.new("name", %NameInput.text.strip_edges(), Parser.ParsedAttribute.OPERATOR_TYPE.EQUAL)
	)
	descriptor.append(
		Parser.ParsedAttribute.new("version", %ModVerInput.text.strip_edges(), Parser.ParsedAttribute.OPERATOR_TYPE.EQUAL)
	)
	descriptor.append(
		Parser.ParsedAttribute.new("supported_version", %GameVerInput.text.strip_edges(), Parser.ParsedAttribute.OPERATOR_TYPE.EQUAL)
	)
	# Tags
	var tags: Array[Parser.ParsedAttribute] = []
	if %AltHistInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Alternative History", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %BalanceInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Balance", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %EventsInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Events", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %FixesInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Fixes", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %GameplayInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Gameplay", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %GraphicsInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Graphics", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %HistoricalInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Historical", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %IdeologiesInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Ideologies", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %MapInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Map", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %MilitaryInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Military", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %NatFocInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("National Focuses", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %SoundInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Sound", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %TechnologiesInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("TTechnologies", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %TranslationInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Translation", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	if %UtilitiesInput.button_pressed:
		tags.append(
			Parser.ParsedAttribute.new("Utilities", "", Parser.ParsedAttribute.OPERATOR_TYPE.NONE)
		)
	
	descriptor.append(
		Parser.ParsedAttribute.new("tags", tags, Parser.ParsedAttribute.OPERATOR_TYPE.EQUAL)
	)
	
	var user_dir := DirAccess.open(Globals.USER_DIR)
	if user_dir == null:
		_display_error(DirAccess.get_open_error())
		return
	
	# Creating mod's folder
	var creation_err := user_dir.make_dir_recursive(
		%PathInput.text.strip_edges()
	)
	if creation_err != OK:
		_display_error(creation_err)
		return
	
	# Creating descriptor.mod
	var descriptor_file = FileAccess.open(
		Globals.USER_DIR+%PathInput.text.strip_edges()+"/descriptor.mod",
		FileAccess.WRITE
	)
	if descriptor_file == null:
		_display_error(FileAccess.get_open_error())
		return
	
	# Saving thumbnail if there is one
	var thumb: Image = null
	if %Thumbnail.texture != null:
		thumb = %Thumbnail.texture.get_image()
	
	var descriptor_str := ""
	for attr: Parser.ParsedAttribute in descriptor:
		descriptor_str += attr.to_string() + "\n"
			
	if thumb == null:
		descriptor_file.store_string(descriptor_str)
	else:
		var desc_c := descriptor_str
		desc_c += \
			Parser.ParsedAttribute.new("picture", "thumbnail.png", Parser.ParsedAttribute.OPERATOR_TYPE.EQUAL).to_string() + "\n"
		descriptor_file.store_string(desc_c)
		DirAccess.copy_absolute(
			%ThumbnailPath.text,
			Globals.USER_DIR+%PathInput.text.strip_edges()+"/thumbnail.png"
		)
	
	# Main mod descriptor file
	var mod_desc_filename: String = %NameInput.text.strip_edges()+".mod"
	mod_desc_filename = mod_desc_filename.validate_filename()
	var mod_desc_file = FileAccess.open(
		Globals.USER_DIR+"mod/"+mod_desc_filename,
		FileAccess.WRITE
	)
	if mod_desc_file == null:
		_display_error(FileAccess.get_open_error())
		return
	
	descriptor_str += \
			Parser.ParsedAttribute.new("path", Globals.USER_DIR+%PathInput.text.strip_edges(),
			Parser.ParsedAttribute.OPERATOR_TYPE.EQUAL).to_string() + "\n"
	mod_desc_file.store_string(descriptor_str)
	
	# Closing
	hide()
	queue_free()
