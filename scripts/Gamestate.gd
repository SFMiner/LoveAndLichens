# GameState.gd
extends Node

var player_position: Vector2 = Vector2.ZERO
var inventory: Array = []
var relationships: Dictionary = {}
var quests: Dictionary = {}
var journal_entries: Array = []
var main_scene








func set_main(new_scene):
	main_scene = new_scene

func get_main():
	return main_scene

func save_game(slot: int = 0):
	var save_data = {
		"player_position": {
			"x": player_position.x,
			"y": player_position.y
		},
		"inventory": inventory,
		"relationships": relationships,
		"quests": quests,
		"journal_entries": journal_entries
	}
	
	var save_file = FileAccess.open("user://save_game_" + str(slot) + ".save", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_data))
	save_file.close()

func load_game(slot: int = 0):
	var save_file = FileAccess.open("user://save_game_" + str(slot) + ".save", FileAccess.READ)
	if save_file:
		var json = JSON.new()
		json.parse(save_file.get_as_text())
		var save_data = json.get_data()
		
		player_position = Vector2(save_data["player_position"]["x"], save_data["player_position"]["y"])
		inventory = save_data["inventory"]
		relationships = save_data["relationships"]
		quests = save_data["quests"]
		journal_entries = save_data["journal_entries"]
		
		save_file.close()
		return true
	return false

func new_game():
	player_position = Vector2.ZERO
	inventory.clear()
	relationships.clear()
	quests.clear()
	journal_entries.clear()
	# Add any initial game state setup here

func add_to_inventory(item: String):
	inventory.append(item)

func remove_from_inventory(item: String):
	inventory.erase(item)

func update_relationship(character: String, value: int):
	if character in relationships:
		relationships[character] += value
	else:
		relationships[character] = value

func add_quest(quest_name: String, quest_data: Dictionary):
	quests[quest_name] = quest_data

func update_quest(quest_name: String, quest_data: Dictionary):
	if quest_name in quests:
		quests[quest_name] = quest_data

func add_journal_entry(entry: String):
	journal_entries.append(entry)
