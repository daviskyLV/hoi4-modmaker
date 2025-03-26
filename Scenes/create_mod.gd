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
	var validated_path = Validator.validate_path(new_text)
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
	
	var descriptor: Array[ScriptParser.ParsedAttribute] = []
	descriptor.append(
		ScriptParser.ParsedAttribute.new(
			"name", %NameInput.text.strip_edges(), ScriptParser.ATTRIBUTE_OPERATOR.EQUAL,
			ScriptParser.ATTRIBUTE_LINE.SAME_LINE
		)
	)
	descriptor.append(
		ScriptParser.ParsedAttribute.new(
			"version", %ModVerInput.text.strip_edges(), ScriptParser.ATTRIBUTE_OPERATOR.EQUAL,
			ScriptParser.ATTRIBUTE_LINE.NEWLINE
		)
	)
	descriptor.append(
		ScriptParser.ParsedAttribute.new(
			"supported_version", %GameVerInput.text.strip_edges(), ScriptParser.ATTRIBUTE_OPERATOR.EQUAL,
			ScriptParser.ATTRIBUTE_LINE.NEWLINE
		)
	)
	# Tags
	var tags: Array[ScriptParser.ParsedAttribute] = []
	if %AltHistInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Alternative History", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %BalanceInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Balance", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %EventsInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Events", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %FixesInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Fixes", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %GameplayInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Gameplay", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %GraphicsInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Graphics", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %HistoricalInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Historical", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %IdeologiesInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Ideologies", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %MapInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Map", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %MilitaryInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Military", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %NatFocInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"National Focuses", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %SoundInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Sound", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %TechnologiesInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Technologies", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %TranslationInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Translation", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	if %UtilitiesInput.button_pressed:
		tags.append(
			ScriptParser.ParsedAttribute.new(
				"Utilities", "", ScriptParser.ATTRIBUTE_OPERATOR.NONE,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			)
		)
	
	descriptor.append(
		ScriptParser.ParsedAttribute.new(
			"tags", tags, ScriptParser.ATTRIBUTE_OPERATOR.EQUAL,
			ScriptParser.ATTRIBUTE_LINE.NEWLINE
		)
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
	for attr: ScriptParser.ParsedAttribute in descriptor:
		descriptor_str += attr.to_string() + "\n"
			
	if thumb == null:
		descriptor_file.store_string(descriptor_str)
	else:
		var desc_c := descriptor_str
		desc_c += \
			ScriptParser.ParsedAttribute.new(
				"picture", "thumbnail.png", ScriptParser.ATTRIBUTE_OPERATOR.EQUAL,
				ScriptParser.ATTRIBUTE_LINE.NEWLINE
			).to_string() + "\n"
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
			ScriptParser.ParsedAttribute.new(
				"path", Globals.USER_DIR+%PathInput.text.strip_edges(),
				ScriptParser.ATTRIBUTE_OPERATOR.EQUAL, ScriptParser.ATTRIBUTE_LINE.NEWLINE
			).to_string() + "\n"
	mod_desc_file.store_string(descriptor_str)
	
	# Closing
	hide()
	queue_free()
