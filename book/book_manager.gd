extends Node

var sections: Dictionary = {}
var current_section_id: String = "1"

var book_ui: Control = null

func _ready() -> void:
	_load_all_sections()

func init(ui: Control) -> void:
	book_ui = ui
	go_to_section("1")

func _load_all_sections() -> void:
	var dir := DirAccess.open("res://book/")
	if dir == null:
		push_error("Dossier res://book/ introuvable")
		return
	
	dir.list_dir_begin()
	var file := dir.get_next()
	
	while file != "":
		if file.ends_with(".tres"):
			var section := load("res://book/" + file) as BookSection
			if section != null and section.id != "":
				sections[section.id] = section
		file = dir.get_next()
	
	dir.list_dir_end()
	print("Sections chargées : ", sections.keys())

func go_to_section(id: String) -> void:
	if not sections.has(id):
		push_error("Section introuvable : " + id)
		return
	
	current_section_id = id
	book_ui.display_section(sections[id])

func trigger_event(section: BookSection) -> void:
	match section.event:
		"combat":
			GameState.set_combat_enemy(
				section.event_data.get("name", "Ennemi"),
				section.event_data.get("skill", 10),
				section.event_data.get("endurance", 20),
				section.event_data.get("return_victory", "1")
			)
			get_tree().change_scene_to_file("res://combat/combat.tscn")
		"game_over":
			get_tree().change_scene_to_file("res://ui/game_over.tscn")
		_:
			push_warning("Événement inconnu : " + section.event)
