extends Control

@onready var lbl_title = $VBoxContainer/Header/TitleLabel
@onready var weapon_list = $VBoxContainer/WeaponList
@onready var add_container = $VBoxContainer/AddContainer
@onready var combo_add = $VBoxContainer/AddContainer/ComboAdd
@onready var btn_add = $VBoxContainer/AddContainer/BtnAdd

const WEAPON_LIST = [
	"Poignard", "Lance", "Masse d'armes", "Coutelas", "Marteau de guerre",
	"Épée", "Hache", "Épée du Soleil", "Glaive", "Bâton"
]

func _ready() -> void:
	GameState.weapons_updated.connect(_on_weapons_updated)
	btn_add.pressed.connect(_on_add_pressed)
	
	combo_add.clear()
	for w in WEAPON_LIST:
		combo_add.add_item(w)
		
	# Init UI
	_on_weapons_updated(GameState.weapons)

func _on_add_pressed() -> void:
	var selected_weapon = WEAPON_LIST[combo_add.selected]
	var success = GameState.add_weapon(selected_weapon)
	if success:
		AudioManager.play_ui_click()

func _on_weapons_updated(weapons: Array) -> void:
	# Nettoyer la liste
	for child in weapon_list.get_children():
		child.queue_free()
		
	# Recréer la liste UI
	for w in weapons:
		var row = HBoxContainer.new()
		
		var lbl = Label.new()
		lbl.text = "⚔️ " + w
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		
		var btn_del = Button.new()
		btn_del.text = "X"
		btn_del.pressed.connect(func(): _on_remove_pressed(w))
		row.add_child(btn_del)
		
		weapon_list.add_child(row)
		
	# Masquer le bouton d'ajout si 2 armes 
	add_container.visible = (weapons.size() < 2)

func _on_remove_pressed(weapon_name: String) -> void:
	AudioManager.play_ui_click()
	GameState.remove_weapon(weapon_name)
