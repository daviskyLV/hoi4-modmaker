extends MarginContainer
class_name ModsTab

func _is_mod_visible(mod_info: Dictionary) -> bool:
	if !mod_info.mod_name.containsn(%Searchbox.text) and \
	!%Searchbox.text.is_empty():
		return false
	
	### TODO: Replace game/mod version searches to support *!
	if !%GameVerInput.text.is_empty() and \
	!mod_info.game_version.containsn(%GameVerInput.text):
		return false
	
	if !%ModVerInput.text.is_empty() and \
	!mod_info.mod_version.containsn(%ModVerInput.text):
		return false
	
	# Tags
	if %AltHistInput.button_pressed and \
	!mod_info.tags.has("Alternative History"):
		return false
	if %BalanceInput.button_pressed and \
	!mod_info.tags.has("Balance"):
		return false
	if %EventsInput.button_pressed and \
	!mod_info.tags.has("Events"):
		return false
	if %FixesInput.button_pressed and \
	!mod_info.tags.has("Fixes"):
		return false
	if %GameplayInput.button_pressed and \
	!mod_info.tags.has("Gameplay"):
		return false
	if %GraphicsInput.button_pressed and \
	!mod_info.tags.has("Graphics"):
		return false
	if %HistoricalInput.button_pressed and \
	!mod_info.tags.has("Historical"):
		return false
	if %IdeologiesInput.button_pressed and \
	!mod_info.tags.has("Ideologies"):
		return false
	if %MapInput.button_pressed and \
	!mod_info.tags.has("Map"):
		return false
	if %MilitaryInput.button_pressed and \
	!mod_info.tags.has("Military"):
		return false
	if %NatFocInput.button_pressed and \
	!mod_info.tags.has("National Focuses"):
		return false
	if %SoundInput.button_pressed and \
	!mod_info.tags.has("Sound"):
		return false
	if %TechnologiesInput.button_pressed and \
	!mod_info.tags.has("Technologies"):
		return false
	if %TranslationInput.button_pressed and \
	!mod_info.tags.has("Translation"):
		return false
	if %UtilitiesInput.button_pressed and \
	!mod_info.tags.has("Utilities"):
		return false
	
	return true

func _recheck_modlist() -> void:
	var mods := %ModlistVBox.get_children()
	
	for node in mods:
		if !(node is ModlistEntry):
			continue
		
		var mod: ModlistEntry = node
		var mod_info: Dictionary = mod.get_mod_info()
		mod.visible = _is_mod_visible(mod_info)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ModlistVBox.modlist_updated.connect(_recheck_modlist)
	%Searchbox.text_changed.connect(func(_new_text: String): _recheck_modlist())
	%GameVerInput.text_changed.connect(func(_new_text: String): _recheck_modlist())
	%ModVerInput.text_changed.connect(func(_new_text: String): _recheck_modlist())
	#Tags
	%AltHistInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%BalanceInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%EventsInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%FixesInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%GameplayInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%GraphicsInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%HistoricalInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%IdeologiesInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%MapInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%MilitaryInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%NatFocInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%SoundInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%TechnologiesInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%TranslationInput.toggled.connect(func(_on: bool): _recheck_modlist())
	%UtilitiesInput.toggled.connect(func(_on: bool): _recheck_modlist())
	
	_recheck_modlist()
