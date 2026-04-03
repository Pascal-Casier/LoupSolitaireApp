extends Node

const SAVE_PATH = "user://savegame.cfg"

# Signaux pour UI
signal save_successful()
signal load_successful()

func save_game() -> void:
	var config = ConfigFile.new()
	var state = GameState.get_state_dict()
	
	# Ajouter la section courante du livre
	state["current_section"] = BookManager.current_section_id
	
	for section in state.keys():
		var value = state[section]
		if typeof(value) == TYPE_DICTIONARY:
			for key in value.keys():
				config.set_value(section, key, value[key])
		else:
			config.set_value("General", section, value)

	var err = config.save(SAVE_PATH)
	if err == OK:
		save_successful.emit()
		print("Jeu sauvegardé dans ", SAVE_PATH)
	else:
		printerr("Erreur lors de la sauvegarde : ", err)

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)

	if err != OK:
		printerr("Fichier de sauvegarde introuvable ou illisible.")
		return
	
	# Restaurer les données
	var loaded_state = {}
	
	# Reconstruire le dictionnaire de stats
	var stats_dict = {}
	if config.has_section("stats"):
		for key in config.get_section_keys("stats"):
			stats_dict[key] = config.get_value("stats", key)
		loaded_state["stats"] = stats_dict
	
	# Reconstruire la section General (tableaux, or, etc.)
	if config.has_section("General"):
		loaded_state["inventory"] = config.get_value("General", "inventory", [])
		loaded_state["special_items"] = config.get_value("General", "special_items", [])
		loaded_state["weapons"] = config.get_value("General", "weapons", [])
		loaded_state["disciplines"] = config.get_value("General", "disciplines", [])
		loaded_state["gold"] = config.get_value("General", "gold", 0)
		loaded_state["notes"] = config.get_value("General", "notes", "")
		loaded_state["has_weapon_mastery"] = config.get_value("General", "has_weapon_mastery", false)
		loaded_state["mastered_weapon"] = config.get_value("General", "mastered_weapon", "")

	GameState.load_state_dict(loaded_state)
	
	# Restaurer la section du livre
	var current_section = config.get_value("General", "current_section", "1")
	BookManager.go_to_section(current_section)
	
	load_successful.emit()
	print("Partie chargée avec succès.")

func reset_game() -> void:
	var dir = DirAccess.open("user://")
	if dir.file_exists("savegame.cfg"):
		dir.remove("savegame.cfg")
	
	# Réinitialiser GameState
	GameState.stats = {
		"base_combat_skill": 10,
		"combat_skill": 10,
		"base_max_endurance": 20,
		"max_endurance": 20,
		"current_endurance": 20
	}
	GameState.inventory = []
	GameState.special_items = []
	GameState.weapons = []
	GameState.disciplines = []
	GameState.gold = 0
	GameState.notes = ""
	GameState.has_weapon_mastery = false
	GameState.mastered_weapon = ""
	GameState.stats_rolled = false
	
	# Émettre les signaux
	GameState.load_state_dict(GameState.get_state_dict())
	
	GameState.return_section = ""
	GameState.current_enemy = {}
	BookManager.go_to_section("1")
	print("Jeu réinitialisé.")

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
