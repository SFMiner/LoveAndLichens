import re
import json

def parse_dialogue(input_text):
	dialogue_data = {}
	current_section = None
	current_options = []

	lines = input_text.strip().split('\n')

	for line in lines:
		line = line.strip()
		if not line:
			continue

		if line.startswith('~'):
			if current_section and current_options:
				dialogue_data[current_section].append({"options": current_options})
				current_options = []
			current_section = line[1:].strip()
			dialogue_data[current_section] = []
		elif line.startswith('-'):
			option = parse_option(line)
			current_options.append(option)
		elif line.startswith('=>'):
			dialogue_data[current_section].append(line)
		elif line.startswith('do.'):
			dialogue_data[current_section].append({"action": line[3:]})
		else:
			dialogue_unit = parse_dialogue_line(line)
			if dialogue_unit:
				dialogue_data[current_section].append(dialogue_unit)

	if current_section and current_options:
		dialogue_data[current_section].append({"options": current_options})

	return dialogue_data

def parse_option(line):
	match = re.match(r'- (.*?)(?:\s+\[if (.*?)\])?\s*(?:=>\s*(\w+))?$', line)
	if match:
		text, condition, next_section = match.groups()
		option = {"text": text.strip()}
		if condition:
			option["condition"] = condition
		if next_section:
			option["next"] = f"=> {next_section}"
		return option
	return {"text": line[1:].strip()}

def parse_dialogue_line(line):
	if ':' in line:
		speaker, text = line.split(':', 1)
		text = text.strip()
		actions = re.findall(r'\[do\.(.*?)\]', text)
		for action in actions:
			text = text.replace(f'[do.{action}]', '')
		dialogue_unit = {"speaker": speaker.strip(), "text": text.strip()}
		if actions:
			dialogue_unit["actions"] = [f"do.{action}" for action in actions]
		return dialogue_unit
	return None

# Example usage
input_text = """
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

parsed_dialogue = parse_dialogue(input_text)
print(json.dumps(parsed_dialogue, indent=2))
