extends Node

class_name DialogueParser

const TRACKING = true  # Set to true to enable debug output

func parse_dialogue(input_text: String) -> Array:
	if TRACKING: print("func parse_dialogue(): Starting function")
	var dialogue_data = []
	var current_section = null
	var current_options = []

	var lines = input_text.strip_edges().split("\n")

	for line in lines:
		line = line.strip_edges()
		if line.is_empty():
			continue

		if TRACKING: print("func parse_dialogue(): Processing line: ", line)

		if line.begins_with("~"):
			if TRACKING: print("func parse_dialogue(): Found new section: ", line)
			if current_section != null and not current_options.is_empty():
				if TRACKING: print("func parse_dialogue(): Adding options to previous section")
				current_section["content"].append({"options": current_options})
				current_options = []
			current_section = {"title": line.substr(1).strip_edges(), "content": []}
			dialogue_data.append(current_section)
			if TRACKING: print("func parse_dialogue(): Created new section: ", current_section["title"])
		elif line.begins_with("-"):
			if TRACKING: print("func parse_dialogue(): Found option: ", line)
			var option = parse_option(line)
			current_options.append(option)
			if TRACKING: print("func parse_dialogue(): Added option: ", option)
		elif line.begins_with("=>"):
			if TRACKING: print("func parse_dialogue(): Found jump: ", line)
			if current_options.is_empty():
				current_section["content"].append(line)
				if TRACKING: print("func parse_dialogue(): Added jump to section: ", current_section["title"])
			else:
				# If we have options, this jump is part of the last option
				current_options[-1]["next"] = line
				if TRACKING: print("func parse_dialogue(): Added jump to last option: ", current_options[-1])
		elif line.begins_with("do."):
			if TRACKING: print("func parse_dialogue(): Found action: ", line)
			current_section["content"].append({"action": line})
			if TRACKING: print("func parse_dialogue(): Added action to section: ", current_section["title"])
		else:
			if TRACKING: print("func parse_dialogue(): Found dialogue line: ", line)
			var dialogue_unit = parse_dialogue_line(line)
			if dialogue_unit:
				current_section["content"].append(dialogue_unit)
				if TRACKING: print("func parse_dialogue(): Added dialogue unit to section: ", current_section["title"])

	# Add any remaining options to the last section
	if current_section != null and not current_options.is_empty():
		if TRACKING: print("func parse_dialogue(): Adding final options to section: ", current_section["title"])
		current_section["content"].append({"options": current_options})

	if TRACKING: print("func parse_dialogue(): Final dialogue data: ", dialogue_data)
	if TRACKING: print("func parse_dialogue(): Ending function")
	return dialogue_data

func parse_option(line: String) -> Dictionary:
	if TRACKING: print("func parse_option(): Starting function with line: ", line)
	var regex = RegEx.new()
	regex.compile(r"- (.*?)(?:\s+\[if (.*?)\])?$")
	var match = regex.search(line)
	if match:
		var text = match.get_string(1).strip_edges()
		var condition = match.get_string(2)
		var option = {"text": text}
		if condition:
			option["condition"] = condition
		if TRACKING: print("func parse_option(): Parsed option: ", option)
		return option
	if TRACKING: print("func parse_option(): Unable to parse option, returning default")
	return {"text": line.substr(1).strip_edges()}

func parse_dialogue_line(line: String) -> Dictionary:
	if TRACKING: print("func parse_dialogue_line(): Starting function with line: ", line)
	if ":" in line:
		var parts = line.split(":", true, 1)
		var speaker = parts[0].strip_edges()
		var text = parts[1].strip_edges()
		var regex = RegEx.new()
		regex.compile(r"\[do\.(.*?)\]")
		var actions = []
		for match in regex.search_all(text):
			actions.append("do." + match.get_string(1))
			text = text.replace(match.get_string(), "")
		var dialogue_unit = {"speaker": speaker, "text": text.strip_edges()}
		if not actions.is_empty():
			dialogue_unit["actions"] = actions
		if TRACKING: print("func parse_dialogue_line(): Parsed dialogue unit: ", dialogue_unit)
		return dialogue_unit
	if TRACKING: print("func parse_dialogue_line(): Unable to parse dialogue line, returning empty dict")
	return {}

# Example usage
func pretty_print_dialogue(dialogue_data: Array, indent: String = "") -> String:
	var result = ""
	for section in dialogue_data:
		result += indent + "~ " + section["title"] + "\n"
		for item in section["content"]:
			if typeof(item) == TYPE_STRING:
				result += indent + "  " + item + "\n"
			elif "speaker" in item:
				result += indent + "  " + item["speaker"] + ": " + item["text"] + "\n"
			elif "action" in item:
				result += indent + "  " + item["action"] + "\n"
			elif "options" in item:
				for option in item["options"]:
					result += indent + "  - " + option["text"]
					if "condition" in option:
						result += " [if " + option["condition"] + "]"
					result += "\n"
					if "next" in option:
						result += indent + "    " + option["next"] + "\n"
		result += "\n"
	return result

# Example usage
func _ready():
	if TRACKING: print("func _ready(): Starting function")
	var input_text = """
~ enter_biology_lab
Player: Wow, this lab is amazing!
=> talk_oakhart

~ talk_oakhart
Dr. Oakhart: Greetings, young scientist! Welcome to our Enchanted Forest Research Station. I'm Dr. Oakhart, the lead botanist here.
Player: It's great to be here, Dr. Oakhart! This forest looks magical.
Dr. Oakhart: Indeed it is! We study the unique flora and fauna of this mystical ecosystem. What brings you to our humble station?
=> oakhart_options_start

~oakhart_options_start
- I'm here to study the magical plants. [if not GameState.get_spoke_oakhart_plants()]
	=> magical_plants
- I'm interested in the enchanted creatures. [if not GameState.get_spoke_oakhart_creatures()]
	=> enchanted_creatures
- Never Mind (leave conversation)
	=> end_conversation

~ magical_plants
do.GameState.set_spoke_oakhart_plants(true)
Dr. Oakhart: Ah, a budding botanist! Our magical plants are truly fascinating...
=> oakhart_options_start

~ enchanted_creatures
do.GameState.set_spoke_oakhart_creatures(true)
Dr. Oakhart: The creatures here are unlike any you've seen before...
=> oakhart_options_start
"""

	if TRACKING: print("func _ready(): Calling parse_dialogue()")
	var parsed_dialogue = parse_dialogue(input_text)
	if TRACKING: print("func _ready(): Parsing complete. Printing result.")
	print(pretty_print_dialogue(parsed_dialogue))
	if TRACKING: print("func _ready(): Ending function")
Last edited 2 minutes ago
