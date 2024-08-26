extends Node

class_name DialogParser

var current_speaker = ""
var current_indent = 0
var dialog_data = {"lines": []}
var option_stack = []

func parse_dialog_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + file_path)
		return {}

	dialog_data = {"lines": []}
	current_speaker = ""
	current_indent = 0
	option_stack = []

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		print("line: ", line)
		if line.is_empty():
			continue
		parse_line(line)
	print(" Dialog_data = ", dialog_data)
	return dialog_data
	

func parse_line(line: String):
	var indent = line.count("\t")
	line = line.strip_edges()

	if line.begins_with("-"):
		parse_option(line, indent)
	elif ":" in line:
		parse_dialog(line)
	else:
		parse_caption(line)

func parse_dialog(line: String):
	var parts = line.split(":", true, 1)
	current_speaker = parts[0].strip_edges()
	print("current_speaker: ", current_speaker)
	var text = parts[1].strip_edges()
	print("parsed dialog: ", text)
	add_dialog_line(text)

func parse_caption(line: String):
	current_speaker = ""
	print("parsed caption: ", line)
	add_dialog_line(line)

func parse_option(line: String, indent: int):
	line = line.substr(1).strip_edges()  # Remove the leading "-"
	var option = {"text": line}

	# Check for character-specific option
	if ":" in line:
		var parts = line.split(":", true, 1)
		option["character"] = parts[0].strip_edges()
		option["text"] = parts[1].strip_edges()

	# Check for actions
	if "do." in option["text"]:
		var parts = option["text"].split("do.", true, 1)
		option["text"] = parts[0].strip_edges()
		option["action"] = parts[1].strip_edges()

	# Check for conditionals
	if "if " in option["text"]:
		var parts = option["text"].split("if ", true, 1)
		option["text"] = parts[0].strip_edges()
		option["condition"] = parts[1].strip_edges()

	if indent > current_indent:
		option_stack[-1]["next"] = {"lines": []}
		option_stack.append(option_stack[-1]["next"])
	elif indent < current_indent:
		for i in range(current_indent - indent):
			option_stack.pop_back()

	current_indent = indent

	if option_stack:
		if not "options" in option_stack[-1]:
			option_stack[-1]["options"] = []
		option_stack[-1]["options"].append(option)
	else:
		dialog_data["lines"][-1]["options"] = [option]
		option_stack = [dialog_data["lines"][-1]]
		print("parsed option: ", option_stack)
		
func add_dialog_line(text: String):
	var line = {"text": text}
	if current_speaker:
		line["speaker"] = current_speaker
	dialog_data["lines"].append(line)
	option_stack = [dialog_data["lines"][-1]]
	current_indent = 0
