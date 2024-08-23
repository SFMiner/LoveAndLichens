extends Control

@onready var panel = $Panel
var file_list
var btn_load_game

var save_directory = "user://"
var selected_file = ""

signal entry_selected(filename)


func _ready():
	print("Load Screan ready")
	file_list = panel.get_node("HSplitContainer/lst_FileList")
	print("file_list = ", file_list)
	btn_load_game = $Panel/HSplitContainer/VBoxContainer/btn_LoadGame
	refresh_file_list()
	btn_load_game.disabled = true

func refresh_file_list():
	file_list.clear()
	var dir = DirAccess.open(save_directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".save"):
				file_list.add_item(file_name)
			file_name = dir.get_next()

func _on_lst_file_list_item_selected(index: int) -> void:
	selected_file = file_list.get_item_text(index)
	btn_load_game.disabled = false

func _on_btn_load_game_pressed() -> void:
	if selected_file != "":
		var save_game = FileAccess.open(save_directory + selected_file, FileAccess.READ)
		if save_game:
			var save_data = save_game.get_var()
			# Process your save data here
			print("Loaded save file: ", selected_file)
			print("Save data: ", save_data)
		else:
			print("Failed to open save file.")

func _on_btn_refresh_pressed() -> void:
	refresh_file_list()
	

# In the function where an entry is selected (e.g., when an item in the list is double-clicked)
func _on_item_activated(index):
	var filename = $ItemList.get_item_text(index)
	emit_signal("entry_selected", filename)
	queue_free()  # Close the load game window after selection
