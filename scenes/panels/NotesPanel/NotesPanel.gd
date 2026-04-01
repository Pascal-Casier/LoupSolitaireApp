extends Control

@onready var text_edit = $VBoxContainer/TextEditNotes

func _ready() -> void:
	GameState.notes_updated.connect(_on_notes_updated)
	
	# Sauvegarde automatique des notes dès qu'elles changent
	text_edit.text_changed.connect(_on_text_changed)
	
	# Init
	_on_notes_updated(GameState.notes)

func _on_text_changed() -> void:
	GameState.set_notes(text_edit.text)

func _on_notes_updated(new_notes: String) -> void:
	# Seulement si différent, pour éviter d'interrompre l'écriture avec le curseur
	if text_edit.text != new_notes:
		text_edit.text = new_notes
