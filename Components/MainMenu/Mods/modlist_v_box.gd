extends VBoxContainer
class_name Modlist

var _last_check := -1
@export_range(1.0, 60.0, 0.1) var checking_interval := 25.0
const MOD_ENTRY = preload("res://Components/MainMenu/Mods/mod_entry.tscn")
signal modlist_updated

func update_modlist() -> void:
	_last_check = Time.get_ticks_msec()
	if !DirAccess.dir_exists_absolute(Globals.USER_DIR+"mod/"):
		return
	
	var mod_dir := DirAccess.open(Globals.USER_DIR+"mod/")
	if mod_dir == null:
		printerr("Failed reading HOI4 mod directory! ", DirAccess.get_open_error())
		return
		
	# Clearing existing modlist
	var mod_nodes = get_children()
	for n in mod_nodes:
		n.free()
	
	# Rescanning mods directory for mods
	mod_dir.include_hidden = true
	var files := mod_dir.get_files()
	for filename in files:
		if !filename.ends_with(".mod"):
			continue
		
		var mod_instancce = MOD_ENTRY.instantiate()
		mod_instancce.update_mod_descriptor(mod_dir.get_current_dir()+"/"+filename)
		add_child(mod_instancce)
	
	modlist_updated.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_modlist()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _last_check + checking_interval*1000 <= Time.get_ticks_msec():
		update_modlist()
