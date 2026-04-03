# game_state.gd — stocke tout ce qui doit persister entre scènes
extends Node

# Données de retour après un événement
var return_section: String = ""
var combat_result: String = ""  # "victory" ou "defeat"

# Tes stats joueur (si pas déjà dans un Autoload)
var player_stats: Dictionary = {}
var inventory: Array = []
