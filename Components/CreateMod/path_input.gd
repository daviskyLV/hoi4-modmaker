extends LineEdit

var _last_path := "mod/"
signal text_validated(validated_text: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_text_changed(text)
	pass # Replace with function body.


func _on_text_changed(new_text: String) -> void:
	var old_caret_pos = caret_column
	var regex = RegEx.new()
	regex.compile("^[\\x00-\\x7F]+$") # Entire string contains only ASCII characters
	var result = regex.search(new_text)
	
	if new_text.length() < 4 or !new_text.begins_with("mod/") or \
	!result:
		text = _last_path
		caret_column = old_caret_pos
		text_validated.emit(_last_path)
		return
	
	
	_last_path = new_text
	text_validated.emit(new_text)
