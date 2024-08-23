extends Node2D
@onready var journal_entry_scene = preload("res://scenes/save_journal.tscn") 

@onready var load_game_scene = preload("res://scenes/load_screen.tscn") 

# Called when the node enters the scene tree for the first time.
var save_directory = "user://journal/"

signal file_loaded(filename)

func _unhandled_input(event):
	if event.is_action_pressed("ui_new_journal_entry"):
		_on_new_journal_entry()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_load_game"):
		_on_load_game()
		get_viewport().set_input_as_handled()

func _on_new_journal_entry():
	var popup = journal_entry_scene.instantiate()
	add_child(popup)
#	popup.popup_centered()
	
func _on_load_game():
	var load_scene = load_game_scene.instantiate()
	add_child(load_scene)
	load_scene.popup_centered()
	# Connect the signal for when an entry is selected
	load_scene.entry_selected.connect(_on_entry_selected)

func _on_entry_selected(filename: String):
	open_journal_entry(filename)

func open_journal_entry(filename: String):
	var file_path = save_directory + filename
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = JSON.parse_string(file.get_as_text())
		if content:
			var popup = journal_entry_scene.instantiate()
			add_child(popup)
			popup.set_entry(content.text, filename)
			popup.popup_centered()
		else:
			print("Error parsing journal entry: ", filename)
	else:
		print("Failed to open journal entry: ", filename)
		
