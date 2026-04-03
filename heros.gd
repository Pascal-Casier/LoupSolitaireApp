extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var book_ui = $TabContainer/Histoire
@onready var btn_save: Button = $TopBar/BtnSave
@onready var btn_load: Button = $TopBar/BtnLoad


func _ready() -> void:
	tab_container.current_tab = 0
	BookManager.init(book_ui)
	
	btn_save.pressed.connect(_on_save)
	btn_load.pressed.connect(_on_load)
	
	# Mettre à jour le bouton Charger selon l'existence d'une save
	btn_load.disabled = not SaveManager.has_save()

func _on_save() -> void:
	SaveManager.save_game()
	# Feedback visuel rapide
	btn_save.text = "✅ Sauvegardé !"
	await get_tree().create_timer(1.5).timeout
	btn_save.text = "💾 Sauvegarder"
	btn_load.disabled = false

func _on_load() -> void:
	SaveManager.load_game()
