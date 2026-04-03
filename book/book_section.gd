class_name BookSection
extends Resource

@export var id: String = ""
@export_multiline var text: String = ""  # multiline dans l'Inspector !
@export var choices: Array[Choice] = []
@export var event: String = ""           # "combat", "shop", "game_over"...
@export var event_data: Dictionary = {}  # { "enemy": "loup", "return": "47" }
# Dans book_section.gd, le Choice peut avoir :
@export var condition: String = ""  # ex: "has_item:cle" ou "stat:force>=5"
