extends LineEdit



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# On initialization sanitizing the text
	_on_text_changed(text)


func _on_text_changed(new_text: String) -> void:
	var unix_style = Validator.validate_path(ProjectSettings.globalize_path(new_text))
	
	if new_text != unix_style:
		var old_pos = caret_column
		text = unix_style
		caret_column = old_pos
