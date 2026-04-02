extends Control

@onready var lbl_combat_title = $VBoxContainer/Header/TitleLabel
@onready var edit_enemy_name = $VBoxContainer/EnemyInfo/NameEdit
@onready var edit_enemy_skill = $VBoxContainer/EnemyInfo/SkillEdit
@onready var edit_enemy_endurance = $VBoxContainer/EnemyInfo/EnduranceEdit
@onready var btn_attack = $VBoxContainer/ActionContainer/BtnAttack
@onready var lbl_combat_log = $VBoxContainer/LogContainer/LogLabel

func _ready() -> void:
	btn_attack.pressed.connect(_on_attack_pressed)
	GameState.combat_log_updated.connect(_on_combat_log)

func _on_attack_pressed() -> void:
	var enemy_skill = edit_enemy_skill.text.to_int()
	var enemy_endurance = edit_enemy_endurance.text.to_int()
	var enemy_name = edit_enemy_name.text
	
	if enemy_name.is_empty():
		enemy_name = "Ennemi"
		
	if enemy_endurance <= 0:
		return # Ennemi déjà mort ou données invalides
		
	AudioManager.play_dice_roll()
	
	# Exécuter le round de combat
	var result = GameState.execute_combat_round(enemy_skill, enemy_endurance, enemy_name)
	
	# Mettre à jour l'UI avec l'endurance restante de l'ennemi (Tween pour l'animation)
	var new_hp = result["new_enemy_hp"]
	
	# Animation visuelle (Tween) du texte
	var tween = create_tween()
	tween.tween_property(edit_enemy_endurance, "modulate", Color(1, 0, 0), 0.2)
	tween.tween_callback(func(): edit_enemy_endurance.text = str(new_hp))
	tween.tween_property(edit_enemy_endurance, "modulate", Color(1, 1, 1), 0.2)
	
	if new_hp <= 0:
		var defeated_text = tr("COMBAT_ENEMY_DEFEATED").replace("%name", enemy_name)
		lbl_combat_log.text += "\n" + defeated_text

func _on_combat_log(log_text: String) -> void:
	lbl_combat_log.text += "\n" + log_text
