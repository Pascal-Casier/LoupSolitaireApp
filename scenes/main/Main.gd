extends Control

@onready var btn_save = $MarginContainer/VBoxContainer/TopBar/BtnSave
@onready var btn_load = $MarginContainer/VBoxContainer/TopBar/BtnLoad
@onready var btn_reset = $MarginContainer/VBoxContainer/TopBar/BtnReset
@onready var btn_lang_fr = $MarginContainer/VBoxContainer/TopBar/LangContainer/BtnFR
@onready var btn_lang_en = $MarginContainer/VBoxContainer/TopBar/LangContainer/BtnEN

func _ready() -> void:
	btn_save.pressed.connect(_on_save_pressed)
	btn_load.pressed.connect(_on_load_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	
	btn_lang_fr.pressed.connect(func(): GameState.change_language("fr"))
	btn_lang_en.pressed.connect(func(): GameState.change_language("en"))
	
	SaveManager.save_successful.connect(_on_save_successful)
	
	# Initialiser l'état au lancement
	if GameState.stats.combat_skill == 10 and GameState.stats.max_endurance == 20:
		# Pas encore tiré
		pass

func _on_save_pressed() -> void:
	SaveManager.save_game()

func _on_load_pressed() -> void:
	SaveManager.load_game()

func _on_reset_pressed() -> void:
	SaveManager.reset_game()

func _on_save_successful() -> void:
	# Afficher un Toast UI
	print("UI: Sauvegarde réussie")
