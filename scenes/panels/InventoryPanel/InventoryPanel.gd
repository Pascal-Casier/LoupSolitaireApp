extends Control

@onready var lbl_counter = $VBoxContainer/CounterLabel
@onready var add_edit = $VBoxContainer/AddContainer/LineEditItem
@onready var btn_add = $VBoxContainer/AddContainer/BtnAdd
@onready var btn_add_meal = $VBoxContainer/AddContainer/BtnMeal
@onready var grid_container = $VBoxContainer/GridContainer

func _ready() -> void:
	GameState.inventory_updated.connect(_on_inventory_updated)
	btn_add.pressed.connect(_on_add_custom_item)
	btn_add_meal.pressed.connect(_on_add_meal)
	
	# Initialiser depuis le modèle
	_on_inventory_updated(GameState.inventory)

func _on_add_custom_item() -> void:
	var item_name = add_edit.text.strip_edges()
	if item_name.is_empty():
		return
		
	var success = GameState.add_item("custom_" + str(randi()), item_name)
	if success:
		add_edit.text = ""
		AudioManager.play_ui_click()

func _on_add_meal() -> void:
	var success = GameState.add_item("meal", "Repas")
	if success:
		AudioManager.play_ui_click()

func _on_inventory_updated(inv: Array) -> void:
	lbl_counter.text = str(inv.size()) + " / 8 Objets"
	
	# Désactiver boutons si plein
	var is_full = inv.size() >= 8
	btn_add.disabled = is_full
	btn_add_meal.disabled = is_full
	
	# Nettoyer l'affichage
	for child in grid_container.get_children():
		child.queue_free()
		
	# Recréer les éléments
	for i in range(inv.size()):
		var item = inv[i]
		
		# Interface pour un objet individuel
		var item_box = PanelContainer.new()
		item_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var h_box = HBoxContainer.new()
		item_box.add_child(h_box)
		
		var icon = Label.new()
		icon.text = "🍗" if item["id"] == "meal" else "🎒"
		h_box.add_child(icon)
		
		var lbl = Label.new()
		lbl.text = item["name"]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		h_box.add_child(lbl)
		
		var btn_del = Button.new()
		btn_del.text = "X"
		var current_index = i # Capture correcte pour la closure
		btn_del.pressed.connect(func(): GameState.remove_item(current_index))
		h_box.add_child(btn_del)
		
		grid_container.add_child(item_box)
