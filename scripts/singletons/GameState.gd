extends Node

# Signaux MVC pour l'interface UI
signal stats_updated(combat_skill, max_endurance, current_endurance)
signal inventory_updated(items)
signal weapons_updated(weapons)
signal disciplines_updated(disciplines)
signal gold_updated(amount)
signal notes_updated(text)
signal special_items_updated(items)
signal combat_log_updated(log)
signal language_changed(lang)

# === DONNÉES DU JEU ===
var stats := {
	"base_combat_skill": 10,
	"combat_skill": 10,
	"base_max_endurance": 20,
	"max_endurance": 20,
	"current_endurance": 20
}

var inventory := [] # Array de dictionnaires: {"id": "repas", "name": "Repas", "amount": 1} - Max 8 objets
var special_items := [] # Array de dictionnaires: {"id": "spec_123", "name": "Objet Ex", "amount": 1}
var weapons := [] # Array de strings (max 2)
var disciplines := [] # Array de strings (max 5)
var gold: int = 0
var notes: String = ""
var stats_rolled: bool = false

# Spécifiques à certaines disciplines
var has_weapon_mastery: bool = false
var mastered_weapon: String = ""

# Table de Combat (Loup Solitaire)
# Ratio de combat de -11 à +11. Chaque sous-tableau correspond au D10 (0 à 9).
# Format [Dégâts Ennemi, Dégâts Joueur]. T = Tué (représenté par -1)
const COMBAT_TABLE = {
	-11: [[0,-1], [0,-1], [0,8],  [0,8],  [1,7],  [2,6],  [3,5],  [4,4],  [5,3],  [6,0]],
	-9:  [[0,-1], [0,8],  [0,7],  [1,7],  [2,6],  [3,6],  [4,5],  [5,4],  [6,3],  [7,0]],
	-7:  [[0,8],  [0,7],  [1,6],  [2,6],  [3,5],  [4,5],  [5,4],  [6,3],  [7,2],  [8,0]],
	-5:  [[0,6],  [1,6],  [2,5],  [3,5],  [4,4],  [5,4],  [6,3],  [7,2],  [8,0],  [9,0]],
	-3:  [[1,6],  [2,5],  [3,5],  [4,4],  [5,4],  [6,3],  [7,2],  [8,0],  [9,0],  [10,0]],
	-1:  [[2,5],  [3,5],  [4,4],  [5,4],  [6,3],  [7,2],  [8,2],  [9,0],  [10,0], [11,0]],
	 0:  [[3,5],  [4,4],  [5,4],  [6,3],  [7,2],  [8,2],  [9,1],  [10,0], [11,0], [12,0]],
	 1:  [[4,5],  [5,4],  [6,3],  [7,3],  [8,2],  [9,2],  [10,1], [11,0], [12,0], [14,0]],
	 3:  [[5,4],  [6,3],  [7,3],  [8,2],  [9,2],  [10,2], [11,1], [12,0], [14,0], [16,0]],
	 5:  [[6,4],  [7,3],  [8,3],  [9,2],  [10,2], [11,1], [12,0], [14,0], [16,0], [18,0]],
	 7:  [[7,4],  [8,3],  [9,2],  [10,2], [11,2], [12,0], [14,0], [16,0], [18,0], [-1,0]],
	 9:  [[8,3],  [9,3],  [10,2], [11,2], [12,2], [14,0], [16,0], [18,0], [-1,0], [-1,0]],
	 11: [[9,3],  [10,2], [11,2], [12,2], [14,0], [16,0], [18,0], [-1,0], [-1,0], [-1,0]]
}

func _ready() -> void:
	# Générer stats initiales au 1er lancement (pour demo)
	randomize()

# === MÉTHODES DE GESTION DES STATS ===

func roll_initial_stats() -> void:
	stats.base_combat_skill = 10 + roll_d10()
	stats.base_max_endurance = 20 + roll_d10()
	stats_rolled = true
	
	stats.combat_skill = stats.base_combat_skill
	stats.max_endurance = stats.base_max_endurance
	stats.current_endurance = stats.max_endurance
	emit_stats()

func modify_current_endurance(amount: int) -> void:
	stats.current_endurance = clampi(stats.current_endurance + amount, 0, stats.max_endurance)
	emit_stats()

func modify_combat_skill(amount: int) -> void:
	stats.base_combat_skill = max(0, stats.base_combat_skill + amount)
	stats.combat_skill = stats.base_combat_skill
	emit_stats()

func get_total_combat_skill() -> int:
	var total = stats.combat_skill
	# Calculer bonus armes/maîtrises
	if weapons.is_empty() and not has_discipline("Guerison"): # Exemple d'absence d'arme (mains nues)
		total -= 4
	elif has_weapon_mastery and equipped_mastery_weapon():
		total += 2
	return total

func equipped_mastery_weapon() -> bool:
	return mastered_weapon != "" and weapons.has(mastered_weapon)

func has_discipline(disc: String) -> bool:
	return disciplines.has(disc)

func emit_stats() -> void:
	stats_updated.emit(get_total_combat_skill(), stats.max_endurance, stats.current_endurance)

# === MÉTHODES DE COMBAT ===

func get_combat_ratio(enemy_skill: int) -> int:
	return get_total_combat_skill() - enemy_skill

func _get_column_key(ratio: int) -> int:
	if ratio <= -11: return -11
	if ratio <= -9: return -9
	if ratio <= -7: return -7
	if ratio <= -5: return -5
	if ratio <= -3: return -3
	if ratio <= -1: return -1
	if ratio == 0: return 0
	if ratio <= 2: return 1
	if ratio <= 4: return 3
	if ratio <= 6: return 5
	if ratio <= 8: return 7
	if ratio <= 10: return 9
	return 11

func execute_combat_round(enemy_skill: int, enemy_endurance: int, enemy_name: String) -> Dictionary:
	var ratio = get_combat_ratio(enemy_skill)
	var roll = roll_d10() # donne de 0 à 9
	
	# Mapping exact du jet sur la grille :
	# Un jet de 1 = index 0. Un jet de 9 = index 8. Un jet de 0 = 10 (meilleur tirage) = index 9.
	var table_idx = roll - 1 if roll > 0 else 9
	
	var table_key = _get_column_key(ratio)
	var result = COMBAT_TABLE[table_key][table_idx]
	
	var enemy_damage = result[0]
	var player_damage = result[1]
	
	# Appliquer les dégâts
	var new_enemy_endurance = enemy_endurance
	if enemy_damage == -1: # Tué
		new_enemy_endurance = 0
	else:
		new_enemy_endurance = max(0, enemy_endurance - enemy_damage)
		
	if player_damage == -1: # Tué
		modify_current_endurance(-stats.current_endurance)
	else:
		modify_current_endurance(-player_damage)
		
	var e_dmg_str = tr("COMBAT_KILLED") if enemy_damage == -1 else str(enemy_damage)
	var p_dmg_str = tr("COMBAT_KILLED") if player_damage == -1 else str(player_damage)
	
	# Log traduit et formaté
	var log_str = tr("COMBAT_LOG_ROUND").replace("%name", enemy_name).replace("%roll", str(roll)).replace("%edmg", e_dmg_str).replace("%pdmg", p_dmg_str)
	combat_log_updated.emit(log_str)
	
	return {"enemy_dmg": enemy_damage, "player_dmg": player_damage, "new_enemy_hp": new_enemy_endurance}

# === INVENTAIRE & OR ===

func add_gold(amount: int) -> void:
	gold = clampi(gold + amount, 0, 50) # Outils Loup Solitaire max 50 couronnes
	gold_updated.emit(gold)

func set_notes(new_notes: String) -> void:
	notes = new_notes
	# Pas d'émission immédiate pour éviter de boucler la frappe clavier, sauf si nécessaire


func add_item(item_id: String, item_name: String) -> bool:
	if inventory.size() >= 8:
		return false # Inventaire plein
	inventory.append({"id": item_id, "name": item_name, "amount": 1})
	inventory_updated.emit(inventory)
	return true

func remove_item(index: int) -> void:
	if index >= 0 and index < inventory.size():
		inventory.remove_at(index)
		inventory_updated.emit(inventory)

# === OBJETS SPECIAUX ===

func add_special_item(item_name: String) -> bool:
	special_items.append({"id": "special_" + str(randi()), "name": item_name, "amount": 1})
	special_items_updated.emit(special_items)
	return true

func remove_special_item(index: int) -> void:
	if index >= 0 and index < special_items.size():
		special_items.remove_at(index)
		special_items_updated.emit(special_items)

# === DISCIPLINES ===

func toggle_discipline(disc_name: String, enabled: bool) -> bool:
	if enabled:
		if disciplines.size() >= 5:
			return false # On ne peut pas en avoir plus de 5
		if not disciplines.has(disc_name):
			disciplines.append(disc_name)
	else:
		if disciplines.has(disc_name):
			disciplines.erase(disc_name)
			
	if disc_name == "Maîtrise des armes":
		has_weapon_mastery = enabled
		if not enabled:
			mastered_weapon = ""
			
	disciplines_updated.emit(disciplines)
	emit_stats() # Pour mettre à jour l'habileté de combat
	return true

func set_mastered_weapon(weapon_name: String) -> void:
	mastered_weapon = weapon_name
	emit_stats()

# === ARMES ===

func add_weapon(weapon_name: String) -> bool:
	if weapons.size() >= 2:
		return false # Max 2 armes
	if weapons.has(weapon_name):
		return false # Déjà équipée
	weapons.append(weapon_name)
	weapons_updated.emit(weapons)
	emit_stats() # Peut changer le ratio si c'est la 1ère arme (enlève malus mains nues)
	return true

func remove_weapon(weapon_name: String) -> void:
	if weapons.has(weapon_name):
		weapons.erase(weapon_name)
		weapons_updated.emit(weapons)
		emit_stats()

# === DIVERS ===

func roll_d10() -> int:
	var num = randi() % 10
	return num

func change_language(lang_code: String) -> void:
	TranslationServer.set_locale(lang_code)
	language_changed.emit(lang_code)

func get_state_dict() -> Dictionary:
	return {
		"stats": stats,
		"inventory": inventory,
		"special_items": special_items,
		"weapons": weapons,
		"disciplines": disciplines,
		"gold": gold,
		"notes": notes,
		"stats_rolled": stats_rolled,
		"has_weapon_mastery": has_weapon_mastery,
		"mastered_weapon": mastered_weapon
	}

func load_state_dict(data: Dictionary) -> void:
	stats = data.get("stats", stats)
	inventory = data.get("inventory", inventory)
	special_items = data.get("special_items", special_items)
	weapons = data.get("weapons", weapons)
	disciplines = data.get("disciplines", disciplines)
	gold = data.get("gold", gold)
	notes = data.get("notes", notes)
	stats_rolled = data.get("stats_rolled", false)
	has_weapon_mastery = data.get("has_weapon_mastery", false)
	mastered_weapon = data.get("mastered_weapon", "")
	
	# Emit all signals to update UI
	emit_stats()
	inventory_updated.emit(inventory)
	special_items_updated.emit(special_items)
	weapons_updated.emit(weapons)
	disciplines_updated.emit(disciplines)
	gold_updated.emit(gold)
	notes_updated.emit(notes)
