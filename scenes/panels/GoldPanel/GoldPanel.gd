extends Control

@onready var lbl_gold = $VBoxContainer/GoldRow/GoldValueLabel
@onready var btn_minus = $VBoxContainer/GoldRow/BtnMinus
@onready var btn_plus = $VBoxContainer/GoldRow/BtnPlus

func _ready() -> void:
	GameState.gold_updated.connect(_on_gold_updated)
	
	btn_plus.pressed.connect(func(): GameState.add_gold(1); AudioManager.play_ui_click())
	btn_minus.pressed.connect(func(): GameState.add_gold(-1); AudioManager.play_ui_click())
	
	_on_gold_updated(GameState.gold)

func _on_gold_updated(amount: int) -> void:
	lbl_gold.text = str(amount)
	
	btn_minus.disabled = (amount <= 0)
	btn_plus.disabled = (amount >= 50)
