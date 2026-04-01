extends Node

var dice_player : AudioStreamPlayer
var ui_player : AudioStreamPlayer

func _ready() -> void:
	# Création des lecteurs audio
	dice_player = AudioStreamPlayer.new()
	add_child(dice_player)
	
	ui_player = AudioStreamPlayer.new()
	add_child(ui_player)

	# Normalement on charerait les sons ici.
	# ex: dice_player.stream = preload("res://assets/sounds/dice_roll.ogg")

func play_dice_roll() -> void:
	if dice_player.stream:
		dice_player.play()

func play_ui_click() -> void:
	if ui_player.stream:
		ui_player.play()
