extends Node

class_name DialogManager

signal dialog_started(character)
signal dialog_ended
signal command_issued(command, params)

var current_dialog : Dictionary
var current_character : CharacterBody2D
var dialog_ui : Control
var dialog_stack : Array = []

func _ready():
	print("DialogManager: _ready() called")
	create_dialog_ui()

func create_dialog_ui():
	print("DialogManager: create_dialog_ui() called")
	dialog_ui = load("res://scenes/Dialog UI.tscn").instantiate()
	if dialog_ui:
		add_child(dialog_ui)
		dialog_ui.z_index = 100
		dialog_ui.visible = false
		dialog_ui.connect("continue_pressed", Callable(self, "continue_dialog"))
		dialog_ui.connect("option_selected", Callable(self, "option_selected"))
		print("DialogManager: dialog_ui created and added to scene tree")
	else:
		push_error("DialogManager: Failed to instantiate Dialog UI")

func start_dialog(dialog_data : Dictionary, character : CharacterBody2D = null):
	print("DialogManager: start_dialog called")
	current_dialog = dialog_data
	current_character = character
	dialog_stack.clear()
	emit_signal("dialog_started", character)
	show_dialog_ui()
	process_next_dialog_element()

func show_dialog_ui():
	print("DialogManager: show_dialog_ui called")
	if dialog_ui:
		dialog_ui.visible = true
		if current_character:
			var global_pos = current_character.global_position
			var viewport = get_viewport()
			if viewport:
				var screen_pos = viewport.get_camera_2d().global_to_screen(global_pos)
				dialog_ui.global_position = screen_pos + Vector2(0, -100)
		print("DialogManager: dialog_ui visibility after show: ", dialog_ui.visible)
	else:
		push_error("DialogManager: dialog_ui is null")

func process_next_dialog_element():
	print("DialogManager: process_next_dialog_element called")
	if current_dialog.has("lines") and current_dialog.lines.size() > 0:
		var line = current_dialog.lines.pop_front()
		if line.has("speaker"):
			dialog_ui.set_speaker(line.speaker)
		else:
			dialog_ui.set_speaker("")
		
		if line.has("text"):
			dialog_ui.set_text(line.text)
		
		if line.has("options"):
			show_options(line.options)
		else:
			dialog_ui.show_continue_button()
	elif dialog_stack.size() > 0:
		current_dialog = dialog_stack.pop_back()
		process_next_dialog_element()
	else:
		end_dialog()

func show_options(options : Array):
	print("DialogManager: show_options called with ", options.size(), " options")
	var valid_options = []
	for option in options:
		if check_condition(option):
			valid_options.append(option)
	dialog_ui.show_options(valid_options)

func check_condition(option : Dictionary) -> bool:
	if not option.has("condition"):
		return true
	# Implement your condition checking logic here
	# For example:
	# return evaluate_condition(option.condition)
	return true  # Placeholder

func option_selected(option):
	print("DialogManager: option_selected called with option: ", option.text)
	if option.has("action"):
		process_action(option.action)
	if option.has("next"):
		dialog_stack.push_back(current_dialog)
		current_dialog = option.next
	process_next_dialog_element()

func process_action(action : String):
	print("DialogManager: process_action called with action: ", action)
	var parts = action.split("(")
	var function_name = parts[0]
	var args = []
	if parts.size() > 1:
		args = parts[1].trim_suffix(")").split(",")
	emit_signal("command_issued", function_name, args)

func continue_dialog():
	print("DialogManager: continue_dialog called")
	process_next_dialog_element()

func end_dialog():
	print("DialogManager: end_dialog called")
	current_dialog = {}
	current_character = null
	dialog_ui.visible = false
	emit_signal("dialog_ended")
