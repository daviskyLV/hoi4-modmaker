extends VBoxContainer

@export var user_dir_input: LineEdit
@export var game_dir_input: LineEdit

func user_dir_changed(new_dir: String) -> void:
	Globals.USER_DIR = new_dir

func game_dir_changed(new_dir: String) -> void:
	Globals.GAME_DIR = new_dir

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if user_dir_input != null:
		user_dir_input.text = Globals.USER_DIR
		user_dir_input.text_changed.connect(user_dir_changed)
	if game_dir_input != null:
		game_dir_input.text = Globals.GAME_DIR
		game_dir_input.text_changed.connect(game_dir_changed)
