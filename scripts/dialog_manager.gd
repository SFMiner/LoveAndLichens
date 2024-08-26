extends Node

class_name DialogManager

var project_debug
var local_debug = true
var script_debug

signal dialog_started(character)
signal dialog_ended
signal command_issued(command, params)

var current_dialog : Dictionary
var current_character : CharacterBody2D
var dialog_ui : Control
var dialog_stack : Array = []

func _ready():
	project_debug = GameState.debugging
	script_debug = project_debug and local_debug
	if script_debug: print(GameState.script_name(self), ":_ready() - Initializing DialogManager")
	create_dialog_ui()

func create_dialog_ui():
	if script_debug: print(GameState.script_name(self), ":create_dialog_ui() - Creating dialog UI")
	dialog_ui = load("res://scenes/Dialog UI.tscn").instantiate()
	if dialog_ui:
		add_child(dialog_ui)
		dialog_ui.z_index = 100
		dialog_ui.visible = false
		dialog_ui.connect("continue_pressed", Callable(self, "continue_dialog"))
		dialog_ui.connect("option_selected", Callable(self, "option_selected"))
		if script_debug: print(GameState.script_name(self), ":create_dialog_ui() - Dialog UI created and added to scene tree")
	else:
		if script_debug: print(GameState.script_name(self), ":create_dialog_ui() - Failed to instantiate Dialog UI")
		push_error("DialogManager: Failed to instantiate Dialog UI")

func start_dialog(dialog_data : Dictionary, character : CharacterBody2D = null):
	if script_debug: print(GameState.script_name(self), ":start_dialog() - Starting dialog")
	current_dialog = dialog_data
	current_character = character
	dialog_stack.clear()
	emit_signal("dialog_started", character)
	show_dialog_ui()
	process_next_dialog_element()

func show_dialog_ui():
	if script_debug: print(GameState.script_name(self), ":show_dialog_ui() - Showing dialog UI")
	if dialog_ui:
		dialog_ui.visible = true
		if current_character:
			var global_pos = current_character.global_position
			var viewport = get_viewport()
			if viewport:
				var screen_pos = viewport.get_camera_2d().global_to_screen(global_pos)
				dialog_ui.global_position = screen_pos + Vector2(0, -100)
		if script_debug: print(GameState.script_name(self), ":show_dialog_ui() - Dialog UI visibility: ", dialog_ui.visible)
	else:
		if script_debug: print(GameState.script_name(self), ":show_dialog_ui() - Dialog UI is null")
		push_error("DialogManager: dialog_ui is null")

func process_next_dialog_element():
	if script_debug: print(GameState.script_name(self), ":process_next_dialog_element() - Processing next dialog element")
	if current_dialog.has("lines") and current_dialog.lines.size() > 0:
		var line = current_dialog.lines[0]
		if line.has("speaker"):
			dialog_ui.set_speaker(line.speaker)
		else:
			dialog_ui.set_speaker("")
		
		if line.has("text"):
			dialog_ui.set_text(line.text)
		
		if line.has("options"):
			if script_debug: print(GameState.script_name(self), ":process_next_dialog_element() - Line has options: ", line.options)
			show_options(line.options)
		else:
			if script_debug: print(GameState.script_name(self), ":process_next_dialog_element() - Line has no options, showing continue button")
			dialog_ui.show_continue_button()
		
		# Don't remove the line here, wait for user input
	elif current_dialog.has("next"):
		if script_debug: print(GameState.script_name(self), ":process_next_dialog_element() - Moving to next dialog")
		current_dialog = current_dialog.next
		process_next_dialog_element()
	elif dialog_stack.size() > 0:
		if script_debug: print(GameState.script_name(self), ":process_next_dialog_element() - No more lines, popping from dialog stack")
		current_dialog = dialog_stack.pop_back()
		process_next_dialog_element()
	else:
		if script_debug: print(GameState.script_name(self), ":process_next_dialog_element() - Dialog ended")
		end_dialog()
		
		

func show_options(options : Array):
	if script_debug: print(GameState.script_name(self), ":show_options() - Showing options: ", options)
	var valid_options = []
	for option in options:
		if check_condition(option):
			valid_options.append(option)
	if script_debug: print(GameState.script_name(self), ":show_options() - Valid options: ", valid_options)
	dialog_ui.show_options(valid_options)

func check_condition(option : Dictionary) -> bool:
	if not option.has("condition"):
		return true
	# Implement your condition checking logic here
	# For now, we'll return true for all conditions
	return true

func option_selected(option):
	if script_debug: print(GameState.script_name(self), ":option_selected() - Option selected: ", option)
	if option.has("action"):
		process_action(option.action)
	if option.has("next"):
		dialog_stack.push_back(current_dialog)
		current_dialog = option.next
	else:
		# If there's no "next", remove the current line
		current_dialog.lines.pop_front()
	process_next_dialog_element()

func process_action(action : String):
	if script_debug: print(GameState.script_name(self), ":process_action() - Processing action: ", action)
	var parts = action.split("(")
	var function_name = parts[0]
	var args = []
	if parts.size() > 1:
		args = parts[1].trim_suffix(")").split(",")
	emit_signal("command_issued", function_name, args)

func continue_dialog():
	if script_debug: print(GameState.script_name(self), ":continue_dialog() - Continuing dialog")
	if current_dialog.has("lines") and current_dialog.lines.size() > 0:
		current_dialog.lines.pop_front()  # Remove the processed line
	process_next_dialog_element()

func end_dialog():
	if script_debug: print(GameState.script_name(self), ":end_dialog() - Ending dialog")
	current_dialog = {}
	current_character = null
	dialog_ui.visible = false
	emit_signal("dialog_ended")
