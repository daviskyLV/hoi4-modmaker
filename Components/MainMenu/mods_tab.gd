extends MarginContainer
class_name ModsTab

func _is_mod_visible(mod_info: Array[ScriptParser.ParsedAttribute]) -> bool:
	var mname_attrs := ScriptParser.search_attribute(mod_info, "name", 1)
	if (mname_attrs.size() > 0 and !%Searchbox.text.is_empty() and
	!mname_attrs[0].argument.containsn(%Searchbox.text)):
		return false
	
	### TODO: Replace game/mod version searches to support *!
	var gver_attrs := ScriptParser.search_attribute(mod_info, "supported_version", 1)
	if (gver_attrs.size() > 0 and !%GameVerInput.text.is_empty() and
	!gver_attrs[0].argument.containsn(%GameVerInput.text)):
		return false
	
	var mver_attrs := ScriptParser.search_attribute(mod_info, "version", 1)
	if (mver_attrs.size() > 0 and !%ModVerInput.text.is_empty() and
	!mver_attrs[0].argument.containsn(%ModVerInput.text)):
		return false
	
	var tag_dict: Dictionary[String, bool] = {}
	var tags_attrs := ScriptParser.search_attribute(mod_info, "tags", 1)
	if tags_attrs.size() > 0:
		for t: ScriptParser.ParsedAttribute in tags_attrs[0].argument:
			tag_dict[t.attribute_name] = true
	
	# Tags
	if %AltHistInput.button_pressed and \
	!tag_dict.has("Alternative History"):
		return false
	if %BalanceInput.button_pressed and \
	!tag_dict.has("Balance"):
		return false
	if %EventsInput.button_pressed and \
	!tag_dict.has("Events"):
		return false
	if %FixesInput.button_pressed and \
	!tag_dict.has("Fixes"):
		return false
	if %GameplayInput.button_pressed and \
	!tag_dict.has("Gameplay"):
		return false
	if %GraphicsInput.button_pressed and \
	!tag_dict.has("Graphics"):
		return false
	if %HistoricalInput.button_pressed and \
	!tag_dict.has("Historical"):
		return false
	if %IdeologiesInput.button_pressed and \
	!tag_dict.has("Ideologies"):
		return false
	if %MapInput.button_pressed and \
	!tag_dict.has("Map"):
		return false
	if %MilitaryInput.button_pressed and \
	!tag_dict.has("Military"):
		return false
	if %NatFocInput.button_pressed and \
	!tag_dict.has("National Focuses"):
		return false
	if %SoundInput.button_pressed and \
	!tag_dict.has("Sound"):
		return false
	if %TechnologiesInput.button_pressed and \
	!tag_dict.has("Technologies"):
		return false
	if %TranslationInput.button_pressed and \
	!tag_dict.has("Translation"):
		return false
	if %UtilitiesInput.button_pressed and \
	!tag_dict.has("Utilities"):
		return false
	
	return true

func _recheck_modlist() -> void:
	var mods := %ModlistVBox.get_children()
	
	for node in mods:
		if !(node is ModlistEntry):
			continue
		
		var mod: ModlistEntry = node
		mod.visible = _is_mod_visible(mod.mod_desc)

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
