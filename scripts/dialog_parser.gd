extends Node

class_name DialogParser

var project_debug
var local_debug = true
var script_debug

var current_speaker = ""
var current_indent = 0
var dialog_data = {"lines": []}
var option_stack = []

func _init():
	project_debug = GameState.debugging
	script_debug = project_debug and local_debug

func parse_dialog_file(file_path: String) -> Dictionary:
	if script_debug: print(GameState.script_name(self), ":parse_dialog_file() - Started parsing file: ", file_path)
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		if script_debug: print(GameState.script_name(self), ":parse_dialog_file() - Failed to open file: ", file_path)
		push_error("Failed to open file: " + file_path)
		return {}

	dialog_data = {"lines": []}
	current_speaker = ""
	current_indent = 0
	option_stack = []

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if script_debug: print(GameState.script_name(self), ":parse_dialog_file() - Parsing line: ", line)
		if line.is_empty():
			continue
		parse_line(line)
	if script_debug: print(GameState.script_name(self), ":parse_dialog_file() - Finished parsing. Dialog data: ", dialog_data)
	return dialog_data

func parse_line(line: String):
	var indent = line.count("\t")
	line = line.strip_edges()

	if line.begins_with("-"):
		if script_debug: print(GameState.script_name(self), ":parse_line() - Parsing option: ", line)
		parse_option(line, indent)
	elif ":" in line:
		if script_debug: print(GameState.script_name(self), ":parse_line() - Parsing dialog: ", line)
		if option_stack:
			# This is a response to the previous option
			var last_option = option_stack[-1]
			if not last_option.has("next"):
				last_option["next"] = {}
			parse_dialog(line, last_option["next"])
		else:
			parse_dialog(line)
	else:
		if script_debug: print(GameState.script_name(self), ":parse_line() - Parsing caption: ", line)
		parse_caption(line)

func parse_dialog(line: String, target_dict = null):
	var parts = line.split(":", true, 1)
	var speaker = parts[0].strip_edges()
	var text = parts[1].strip_edges()
	if script_debug: print(GameState.script_name(self), ":parse_dialog() - Speaker: ", speaker, ", Text: ", text)
	
	if target_dict != null:
		target_dict["speaker"] = speaker
		target_dict["text"] = text
	else:
		current_speaker = speaker
		add_dialog_line(text)

func parse_caption(line: String):
	current_speaker = ""
	if script_debug: print(GameState.script_name(self), ":parse_caption() - Caption: ", line)
	add_dialog_line(line)

func parse_option(line: String, indent: int):
	line = line.substr(1).strip_edges()  # Remove the leading "-"
	var option = {"text": line}

	if script_debug: print(GameState.script_name(self), ":parse_option() - Parsing option: ", line, ", Indent: ", indent)

	# Check for character-specific option
	if ":" in line:
		var parts = line.split(":", true, 1)
		option["character"] = parts[0].strip_edges()
		option["text"] = parts[1].strip_edges()

	# Check for actions
	if "(do." in option["text"]:
		var parts = option["text"].split("(do.", true, 1)
		option["text"] = parts[0].strip_edges()
		option["action"] = parts[1].trim_suffix(")").strip_edges()

	# Check for conditionals
	if "(if " in option["text"]:
		var parts = option["text"].split("(if ", true, 1)
		option["text"] = parts[0].strip_edges()
		option["condition"] = parts[1].trim_suffix(")").strip_edges()

	if indent > current_indent:
		if script_debug: print(GameState.script_name(self), ":parse_option() - Adding nested option")
		if option_stack and option_stack[-1].has("options"):
			option_stack[-1]["options"].append(option)
		else:
			if script_debug: print(GameState.script_name(self), ":parse_option() - Error: Cannot add nested option, no parent option found")
	elif indent < current_indent:
		if script_debug: print(GameState.script_name(self), ":parse_option() - Moving back up the option stack")
		for i in range(current_indent - indent):
			option_stack.pop_back()
		if option_stack:
			if not "options" in option_stack[-1]:
				option_stack[-1]["options"] = []
			option_stack[-1]["options"].append(option)
		else:
			if script_debug: print(GameState.script_name(self), ":parse_option() - Error: Option stack is empty after moving up")
	else:
		if script_debug: print(GameState.script_name(self), ":parse_option() - Adding option at current level")
		if option_stack:
			if not "options" in option_stack[-1]:
				option_stack[-1]["options"] = []
			option_stack[-1]["options"].append(option)
		else:
			if not dialog_data["lines"][-1].has("options"):
				dialog_data["lines"][-1]["options"] = []
			dialog_data["lines"][-1]["options"].append(option)

	current_indent = indent
	option_stack.append(option)  # Add the current option to the stack for potential nested options

	if script_debug: print(GameState.script_name(self), ":parse_option() - Current option stack: ", option_stack)
	if script_debug: print(GameState.script_name(self), ":parse_option() - Current dialog_data: ", dialog_data)
	
func add_dialog_line(text: String):
	var line = {"text": text}
	if current_speaker:
		line["speaker"] = current_speaker
	dialog_data["lines"].append(line)
	option_stack = [dialog_data["lines"][-1]]
	current_indent = 0
	if script_debug: print(GameState.script_name(self), ":add_dialog_line() - Added line: ", line)
