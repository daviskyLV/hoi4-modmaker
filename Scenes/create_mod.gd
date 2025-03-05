extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	force_native = true
	
	_on_thumbnail_path_text_changed(%ThumbnailPath.text)
	
	show()

func _recheck_conditions() -> void:
	if %NameInput.text.strip_edges().is_empty():
		%Create.disabled = true
		return
		
	if %PathInput.text.strip_edges().trim_prefix("mod/").is_empty():
		%Create.disabled = true
		return
		
	
	
	%Create.disabled = false

func _tag_toggled(toggled_on: bool) -> void:
	_recheck_conditions()

func _on_close_requested() -> void:
	hide()
	queue_free()
	pass # Replace with function body.


func _on_thumbnail_path_text_changed(new_text: String) -> void:
	var validated_path = Globals.validate_path(new_text)
	# Setting thumbnail image
	var thumb_image := Image.load_from_file(validated_path)
	var thumb_texture = ImageTexture.create_from_image(thumb_image)
	%Thumbnail.texture = thumb_texture


func _on_path_input_text_validated(validated_text: String) -> void:
	_recheck_conditions()
