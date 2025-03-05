extends Button

@export var thumbnail: TextureRect
@export var path_input: LineEdit
@export var topmost_parent: Control

var _file_dialog: FileDialog

func _show_file_dialog(path: String) -> void:
	_file_dialog = FileDialog.new()
	_file_dialog.current_dir = ProjectSettings.globalize_path(path)
	_file_dialog.title = "Select a thumbnail"
	_file_dialog.show_hidden_files = true
	_file_dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	_file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	_file_dialog.add_filter("*.png, *.jpg", "Images")
	_file_dialog.set_use_native_dialog(true) ## To open as native file explorer
	_file_dialog.connect("file_selected", _on_file_selected)
	topmost_parent.add_child.call_deferred(_file_dialog)
	_file_dialog.visible = true

func _on_file_selected(path: String) -> void:
	var validated_path = Globals.validate_path(path)
	path_input.text = validated_path
	# Setting thumbnail image
	var thumb_image := Image.load_from_file(validated_path)
	var thumb_texture = ImageTexture.create_from_image(thumb_image)
	thumbnail.texture = thumb_texture
	_file_dialog.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if thumbnail == null:
		var parent = get_parent()
		if parent is TextureRect:
			thumbnail = parent
		else:
			push_error("No valid thumbnail node set for thumbnail selector!")


func _on_pressed() -> void:
	if thumbnail == null:
		return
	
	_show_file_dialog(path_input.text)
