extends Control

@onready var lbl_combat_skill_val = $VBoxContainer/SkillRow/SkillValueLabel
@onready var btn_cs_minus = $VBoxContainer/SkillRow/BtnMinus
@onready var btn_cs_plus = $VBoxContainer/SkillRow/BtnPlus
@onready var lbl_endurance_val = $VBoxContainer/EnduranceRow/EnduranceValueLabel
@onready var btn_endurance_minus = $VBoxContainer/EnduranceRow/BtnMinus
@onready var btn_endurance_plus = $VBoxContainer/EnduranceRow/BtnPlus
@onready var btn_roll_stats = $VBoxContainer/BtnRollStats

func _ready() -> void:
	# 1. Connexion aux signaux UI
	btn_cs_minus.pressed.connect(_on_cs_minus)
	btn_cs_plus.pressed.connect(_on_cs_plus)
	btn_endurance_minus.pressed.connect(_on_endurance_minus)
	btn_endurance_plus.pressed.connect(_on_endurance_plus)
	btn_roll_stats.pressed.connect(_on_roll_stats)
	
	# 2. Connexion au Modèle (GameState)
	GameState.stats_updated.connect(_on_stats_updated)
	
	# 3. Forcer une mise à jour initiale de l'UI
	GameState.emit_stats()

func _on_endurance_minus() -> void:
	GameState.modify_current_endurance(-1)
	AudioManager.play_ui_click()

func _on_endurance_plus() -> void:
	GameState.modify_current_endurance(1)
	AudioManager.play_ui_click()

func _on_cs_minus() -> void:
	GameState.modify_combat_skill(-1)
	AudioManager.play_ui_click()

func _on_cs_plus() -> void:
	GameState.modify_combat_skill(1)
	AudioManager.play_ui_click()

func _on_roll_stats() -> void:
	AudioManager.play_dice_roll()
	GameState.roll_initial_stats()
	# Une fois tirées, on pourrait cacher ce bouton
	btn_roll_stats.visible = false

# Cette fonction est appelée automatiquement dès que GameState modifie les stats
func _on_stats_updated(combat_skill: int, max_endurance: int, current_endurance: int) -> void:
	lbl_combat_skill_val.text = str(combat_skill)
	lbl_endurance_val.text = str(current_endurance) + " / " + str(max_endurance)
	
	# Gestion visuelle de couleur selon l'endurance
	if current_endurance <= (max_endurance * 0.25):
		lbl_endurance_val.modulate = Color(1, 0.2, 0.2) # Rouge pour <= 25%
	else:
		lbl_endurance_val.modulate = Color(1, 1, 1) # Blanc normal

	# Activer/Désactiver les boutons de +1 et -1 selon les limites
	btn_endurance_plus.disabled = (current_endurance >= max_endurance)
	btn_endurance_minus.disabled = (current_endurance <= 0)
	btn_cs_minus.disabled = (combat_skill <= 0)
	
	btn_roll_stats.visible = not GameState.stats_rolled
