extends Node

@onready var journal_entry_scene = preload("res://scenes/save_journal.tscn") 

@onready var load_game_scene = preload("res://scenes/load_screen.tscn") 

@onready var theme_1 = preload("res://themes/Main_theme.tres")
@onready var window_theme = preload("res://themes/WindowTheme.tres")
@onready var dialog_manager = $DialogManager
@onready var level = $Level

func _ready():
	GameState.set_main(self)
	GameState.print_test("GameState.print_test() is working")
	print("scriptname = ", GameState.script_name(self))

var save_directory = "user://journal/"

signal file_loaded(filename)

func _unhandled_input(event):
	if event.is_action_pressed("ui_open_journal"):
		_on_open_journal()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_new_journal_entry"):
		_on_new_journal_entry()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_load_game"):
		_on_load_game()
		get_viewport().set_input_as_handled()


func _on_open_journal():
	var file_dialog = FileDialog.new()
#	file_dialog.borderless = true(
	file_dialog.theme = window_theme
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_USERDATA
	file_dialog.current_dir = save_directory
	file_dialog.filters = ["*.json"]
#	file_dialog.theme = theme_1
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2(500, 400))
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("#a66744")  
	
	file_dialog.add_theme_stylebox_override("panel", panel_style)
	file_dialog.file_selected.connect(_on_journal_file_selected)

func _on_journal_file_selected(path):
	var filename = path.get_file()
	open_journal_entry(filename)

func open_journal_entry(filename: String):
	var file_path = save_directory + filename
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = JSON.parse_string(file.get_as_text())
		if content and "text" in content:
			var popup = journal_entry_scene.instantiate()
			add_child(popup)
			popup.set_entry(content.text, filename)

		else:
			print("Error parsing journal entry: ", filename)
	else:
		print("Failed to open journal entry: ", filename)
		


func _on_new_journal_entry():
	var popup = journal_entry_scene.instantiate()
	add_child(popup)
#	popup.popup_centered()
	
func _on_load_game():
	var load_scene = load_game_scene.instantiate()
	add_child(load_scene)
#	load_scene.popup_centered()
	# Connect the signal for when an entry is selected
	load_scene.entry_selected.connect(_on_entry_selected)

func _on_entry_selected(filename: String):
	open_journal_entry(filename)
