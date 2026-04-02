extends Control

@onready var add_edit = $VBoxContainer/AddContainer/LineEditItem
@onready var btn_add = $VBoxContainer/AddContainer/BtnAdd
@onready var grid_container = $VBoxContainer/GridContainer

func _ready() -> void:
	GameState.special_items_updated.connect(_on_special_items_updated)
	btn_add.pressed.connect(_on_add_custom_item)
	
	# Initialiser depuis le modèle
	_on_special_items_updated(GameState.special_items)

func _on_add_custom_item() -> void:
	var item_name = add_edit.text.strip_edges()
	if item_name.is_empty():
		return
		
	var success = GameState.add_special_item(item_name)
	if success:
		add_edit.text = ""
		AudioManager.play_ui_click()

func _on_special_items_updated(items: Array) -> void:
	# Nettoyer l'affichage
	for child in grid_container.get_children():
		child.queue_free()
		
	# Recréer les éléments
	for i in range(items.size()):
		var item = items[i]
		
		# Interface pour un objet individuel
		var item_box = PanelContainer.new()
		item_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var h_box = HBoxContainer.new()
		item_box.add_child(h_box)
		
		var icon = Label.new()
		icon.text = "💎" # Diamond as special item icon
		h_box.add_child(icon)
		
		var lbl = Label.new()
		lbl.text = item["name"]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		h_box.add_child(lbl)
		
		var btn_del = Button.new()
		btn_del.text = "X"
		var current_index = i # Capture correcte pour la closure
		btn_del.pressed.connect(func(): GameState.remove_special_item(current_index))
		h_box.add_child(btn_del)
		
		grid_container.add_child(item_box)
