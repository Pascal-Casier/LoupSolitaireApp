extends Control

const LONE_WOLF_DISCIPLINES = [
	"Camouflage",
	"Chasse",
	"Sixième Sens",
	"Orientation",
	"Guérison",
	"Maîtrise des armes",
	"Bouclier Psychique",
	"Puissance Psychique",
	"Communication Animale",
	"Maîtrise de la Matière"
]

const WEAPON_LIST = [
	"Poignard", "Lance", "Masse d'armes", "Coutelas", "Marteau de guerre",
	"Épée", "Hache", "Épée du Soleil", "Glaive", "Bâton"
]

@onready var lbl_counter = $VBoxContainer/CounterLabel
@onready var list_container = $VBoxContainer/ListContainer
@onready var mastery_container = $VBoxContainer/MasteryContainer
@onready var mastery_combo = $VBoxContainer/MasteryContainer/WeaponOptionButton

var checkboxes: Array[CheckBox] = []

func _ready() -> void:
	GameState.disciplines_updated.connect(_on_disciplines_updated)
	
	# Construire les choix d'armes
	mastery_combo.clear()
	for w in WEAPON_LIST:
		mastery_combo.add_item(w)
		
	mastery_combo.item_selected.connect(_on_weapon_selected)
	
	# Générer les Checkboxes dynamiquement
	for disc_name in LONE_WOLF_DISCIPLINES:
		var cb = CheckBox.new()
		cb.text = disc_name
		cb.toggled.connect(func(toggled): _on_checkbox_toggled(cb, disc_name, toggled))
		list_container.add_child(cb)
		checkboxes.append(cb)
		
	# Synchroniser avec l'état initial
	_on_disciplines_updated(GameState.disciplines)

func _on_checkbox_toggled(cb: CheckBox, disc_name: String, toggled_on: bool) -> void:
	AudioManager.play_ui_click()
	var success = GameState.toggle_discipline(disc_name, toggled_on)
	
	# Si l'ajout est rejeté (ex: déjà 5), on annule visuellement sans relancer de signal
	if not success and toggled_on:
		cb.set_pressed_no_signal(false)

func _on_weapon_selected(index: int) -> void:
	var weapon_name = WEAPON_LIST[index]
	GameState.set_mastered_weapon(weapon_name)

func _on_disciplines_updated(current_disciplines: Array) -> void:
	lbl_counter.text = str(current_disciplines.size()) + " / 5 Disciplines"
	
	# Mettre à jour les checkboxes au cas où rechargement de sauvegarde
	for cb in checkboxes:
		cb.set_pressed_no_signal(current_disciplines.has(cb.text))
		
	# Gérer l'affichage du menu d'armes
	var has_mastery = current_disciplines.has("Maîtrise des armes")
	mastery_container.visible = has_mastery
	
	if has_mastery and GameState.mastered_weapon != "":
		# Retrouver l'index de l'arme et l'afficher
		var idx = WEAPON_LIST.find(GameState.mastered_weapon)
		if idx >= 0:
			mastery_combo.select(idx)
		else:
			GameState.set_mastered_weapon(WEAPON_LIST[0])
			mastery_combo.select(0)
	elif has_mastery and GameState.mastered_weapon == "":
		GameState.set_mastered_weapon(WEAPON_LIST[0])
		mastery_combo.select(0)
