extends TextureRect

@export var label_folder: Label
@export var line_edit_folder: LineEdit
@export var open_as_selection: bool = false
@export var topmost_parent: Control

var _file_dialog: FileDialog

func _show_file_dialog(path: String) -> void:
	_file_dialog = FileDialog.new()
	_file_dialog.current_dir = ProjectSettings.globalize_path(path)
	_file_dialog.title = "Select a directory"
	_file_dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_DIR)
	_file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	_file_dialog.set_use_native_dialog(true) ## To open as native file explorer
	_file_dialog.connect("dir_selected", _on_dir_selected)
	topmost_parent.add_child.call_deferred(_file_dialog)
	_file_dialog.visible = true

func _on_button_pressed() -> void:
	var path: String = ""
	if label_folder != null:
		path = label_folder.text
	if line_edit_folder != null:
		path = line_edit_folder.text
	
	if path.is_empty():
		_show_file_dialog(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
		return
	
	if !open_as_selection:
		OS.shell_open(ProjectSettings.globalize_path(path))
	else:
		_show_file_dialog(path)

func _on_dir_selected(path):
	if label_folder != null:
		label_folder.text = Validator.validate_path(path+"/")
		_file_dialog.queue_free()
	if line_edit_folder != null:
		line_edit_folder.text = Validator.validate_path(path+"/")
		_file_dialog.queue_free()
