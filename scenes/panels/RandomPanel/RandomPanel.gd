extends Control

@onready var lbl_result = $VBoxContainer/ResultContainer/ResultLabel
@onready var btn_roll = $VBoxContainer/BtnRoll
@onready var lbl_history = $VBoxContainer/HistoryLabel

var history: Array = []

func _ready() -> void:
	btn_roll.pressed.connect(_on_roll_pressed)
	lbl_result.text = "🎲"
	lbl_history.text = "Historique : -"

func _on_roll_pressed() -> void:
	# Désactiver le bouton pendant l'animation pour éviter le spam
	btn_roll.disabled = true
	AudioManager.play_dice_roll()
	
	# Créer une animation visuelle (faux tirages) à l'aide d'un Tween
	var tween = create_tween()
	var cycles = 10 # Nombre de fois que le chiffre va changer avant de s'arrêter
	
	for i in range(cycles):
		tween.tween_callback(func(): lbl_result.text = str(randi() % 10))
		tween.tween_interval(0.05)
		
	# À la fin de l'animation, on révèle le résultat définitif tiré depuis le GameState
	tween.tween_callback(_finalize_roll)

func _finalize_roll() -> void:
	var final_result = GameState.roll_d10()
	
	# Affichage final avec couleur légèrement modifiée pour signaler la fin
	lbl_result.text = str(final_result)
	lbl_result.modulate = Color(1, 0.8, 0) # Flash doré
	
	var return_tween = create_tween()
	return_tween.tween_property(lbl_result, "modulate", Color(1, 1, 1), 0.3)
	
	# Gestion de la liste d'historique (garde les 5 derniers max)
	history.insert(0, final_result)
	if history.size() > 5:
		history.pop_back()
		
	var hist_str = "Historique : "
	for i in range(history.size()):
		hist_str += str(history[i])
		if i < history.size() - 1:
			hist_str += ", "
			
	lbl_history.text = hist_str
	btn_roll.disabled = false
