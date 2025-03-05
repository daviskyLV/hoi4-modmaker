extends Button

const CREATE_MOD = preload("res://Scenes/create_mod.tscn")
@export var topmost_parent: Control

func _on_pressed() -> void:
	var newmod_instance = CREATE_MOD.instantiate()
	topmost_parent.add_child(newmod_instance)
