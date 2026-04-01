extends Node

const SAVE_PATH = "user://savegame.cfg"

# Signaux pour UI
signal save_successful()
signal load_successful()

func save_game() -> void:
	var config = ConfigFile.new()
	var state = GameState.get_state_dict()
	
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
		loaded_state["weapons"] = config.get_value("General", "weapons", [])
		loaded_state["disciplines"] = config.get_value("General", "disciplines", [])
		loaded_state["gold"] = config.get_value("General", "gold", 0)
		loaded_state["notes"] = config.get_value("General", "notes", "")
		loaded_state["has_weapon_mastery"] = config.get_value("General", "has_weapon_mastery", false)
		loaded_state["mastered_weapon"] = config.get_value("General", "mastered_weapon", "")

	GameState.load_state_dict(loaded_state)
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
	GameState.weapons = []
	GameState.disciplines = []
	GameState.gold = 0
	GameState.notes = ""
	GameState.has_weapon_mastery = false
	GameState.mastered_weapon = ""
	GameState.stats_rolled = false
	
	# Émettre les signaux
	GameState.load_state_dict(GameState.get_state_dict())
	print("Jeu réinitialisé.")
