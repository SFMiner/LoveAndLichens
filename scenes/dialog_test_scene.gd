# DialogueSystemTest.gd
extends Node

const TRACKING = false	# Set to false to disable debug output

# UI elements
#@onready var speaker_label = $SpeakerLabel
#@onready var text_label = $TextLabel
#@onready var continue_button = $ContinueButton
#@onready var options_container = $OptionsContainer

var dialogue_manager
var test_dialogue_data = {
	"enter_biology_lab": [
		{"speaker": "Player", "text": "Wow, this lab is amazing!"},
		"=> talk_oakhart"
	],
	"talk_oakhart": [
		{"speaker": "Dr. Oakhart", "text": "Greetings, young scientist! Welcome to our Enchanted Forest Research Station. I'm Dr. Oakhart, the lead botanist here."},
		{"speaker": "Player", "text": "It's great to be here, Dr. Oakhart! This forest looks magical."},
		{"speaker": "Dr. Oakhart", "text": "Indeed it is! We study the unique flora and fauna of this mystical ecosystem. What brings you to our humble station?"},
		"=> oakhart_options_start"
	],
	"oakhart_options_start": [
		{"options": [
			{
				"text": "I'm here to study the magical plants.", 
				"next": "=> magical_plants",
				"condition": "not GameState.get_spoke_oakhart_plants()"
			},
			{
				"text": "I'm interested in the enchanted creatures.", 
				"next": "=> enchanted_creatures",
				"condition": "not GameState.get_spoke_oakhart_creatures()"
			},
			{"text": "Never Mind (leave conversation)", "next": "=> end_conversation"}
		]}
	],
	"magical_plants": [
		{"speaker": "Dr. Oakhart", "text": "Ah, a budding botanist! Our magical plants are truly fascinating..."},
		{"action": "GameState.set_spoke_oakhart_plants(true)"},
		"=> oakhart_options_start"
	],
	"enchanted_creatures": [
		{"speaker": "Dr. Oakhart", "text": "The creatures here are unlike any you've seen before..."},
		{"action": "GameState.set_spoke_oakhart_creatures(true)"},
		"=> oakhart_options_start"
	]
}

func _ready():
	if TRACKING: print("func _ready(): Starting function")
	dialogue_manager = DialogueManager.new()
	dialogue_manager.dialogue_data = test_dialogue_data
	add_child(dialogue_manager)
	
	# Connect signals
	dialogue_manager.connect("dialogue_started", Callable(self, "_on_dialogue_started"))
	dialogue_manager.connect("dialogue_text_displayed", Callable(self, "_on_dialogue_text_displayed"))
	dialogue_manager.connect("dialogue_options_displayed", Callable(self, "_on_dialogue_options_displayed"))
	dialogue_manager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
	
	# Set initial game state for testing
#	GameState.set_spoke_oakhart_creatures(true)
	
	# Start the test
	if TRACKING: print("func _ready(): Starting dialogue test...")
	dialogue_manager.start_dialogue("enter_biology_lab")
	if TRACKING: print("func _ready(): Ending function")

func _on_dialogue_started(start_title):
	if TRACKING: print("func _on_dialogue_started(): Dialogue started at title: " + start_title)

func _on_dialogue_text_displayed(speaker, text):
	print(speaker + ": " + text)	# This will always print, regardless of TRACKING

func _on_dialogue_options_displayed(options):
	print("Options:")	# This will always print
	for i in range(options.size()):
		print(str(i+1) + ". " + options[i]["text"])	# This will always print
	
	# Simulate user input
	var choice = randi() % options.size()
	print("Choosing option " + str(choice+1))	# This will always print
	dialogue_manager.process_option(options[choice])

func _on_dialogue_ended():
	print("Dialogue ended")	# This will always print

# Simplified DialogueManager for testing
class DialogueManager extends Node:
	signal dialogue_started(start_title)
	signal dialogue_text_displayed(speaker, text)
	signal dialogue_options_displayed(options)
	signal dialogue_ended
	
	var dialogue_data = {}
	var current_title = ""
	var dialogue_queue = []
	
	func start_dialogue(start_title):
		if TRACKING: print("func start_dialogue(): Starting with title: " + start_title)
		current_title = start_title
		if current_title in dialogue_data:
			dialogue_queue = dialogue_data[current_title].duplicate()
			if TRACKING: print("func start_dialogue(): Queue set to: " + str(dialogue_queue))
			emit_signal("dialogue_started", current_title)
			process_next_in_queue()
		else:
			push_error("func start_dialogue(): Error: Dialogue title not found: " + current_title)
		if TRACKING: print("func start_dialogue(): Ending function")
	
	func process_next_in_queue():
		if TRACKING: print("func process_next_in_queue(): Starting function")
		if TRACKING: print("func process_next_in_queue(): Current queue: " + str(dialogue_queue))
		if dialogue_queue.size() > 0:
			var next_unit = dialogue_queue.pop_front()
			if TRACKING: print("func process_next_in_queue(): Processing unit: " + str(next_unit))
			process_dialogue_unit(next_unit)
		else:
			if TRACKING: print("func process_next_in_queue(): Queue empty, ending dialogue")
			end_dialogue()
		if TRACKING: print("func process_next_in_queue(): Ending function")
	
	func process_dialogue_unit(unit):
		if TRACKING: print("func process_dialogue_unit(): Starting function with unit: " + str(unit))
		if typeof(unit) == TYPE_STRING and unit.begins_with("=>"):
			if TRACKING: print("func process_dialogue_unit(): Jumping to title: " + unit.substr(2).strip_edges())
			jump_to_title(unit.substr(2).strip_edges())
		elif "text" in unit:
			if TRACKING: print("func process_dialogue_unit(): Displaying text")
			emit_signal("dialogue_text_displayed", unit["speaker"], unit["text"])
			process_next_in_queue()
		elif "options" in unit:
			if TRACKING: print("func process_dialogue_unit(): Displaying options")
			var valid_options = []
			for option in unit["options"]:
				if "condition" in option:
					if eval_condition(option["condition"]):
						valid_options.append(option)
				else:
					valid_options.append(option)
			emit_signal("dialogue_options_displayed", valid_options)
		elif "action" in unit:
			if TRACKING: print("func process_dialogue_unit(): Executing action")
			execute_action(unit["action"])
			process_next_in_queue()
		else:
			push_error("func process_dialogue_unit(): Invalid dialogue unit: " + str(unit))
		if TRACKING: print("func process_dialogue_unit(): Ending function")

	func eval_condition(condition):
		if TRACKING: print("func eval_condition(): Evaluating condition: " + condition)
		match condition:
			"not GameState.get_spoke_oakhart_plants()":
				return not GameState.get_spoke_oakhart_plants()
			"not GameState.get_spoke_oakhart_creatures()":
				return not GameState.get_spoke_oakhart_creatures()
			_:
				push_error("func eval_condition(): Unknown condition: " + condition)
				return false

	func execute_action(action):
		if TRACKING: print("func execute_action(): Executing action: " + action)
		print("(do." + action + ")")
		match action:
			"GameState.set_spoke_oakhart_plants(true)":
				GameState.set_spoke_oakhart_plants(true)
			"GameState.set_spoke_oakhart_creatures(true)":
				GameState.set_spoke_oakhart_creatures(true)
			_:
				push_error("func execute_action(): Unknown action: " + action)
		
	func jump_to_title(title):
		if TRACKING: print("func jump_to_title(): Starting function with title: " + title)
		if title == "end_conversation":
			if TRACKING: print("func jump_to_title(): Ending conversation")
			end_dialogue()
		else:
			current_title = title
			if current_title in dialogue_data:
				dialogue_queue = dialogue_data[current_title].duplicate()
				if TRACKING: print("func jump_to_title(): Queue set to: " + str(dialogue_queue))
				process_next_in_queue()
			else:
				push_error("func jump_to_title(): Error: Dialogue title not found: " + current_title)
		if TRACKING: print("func jump_to_title(): Ending function")
	
	func process_option(option):
		if TRACKING: print("func process_option(): Starting function with option: " + str(option))
		if "next" in option:
			if typeof(option["next"]) == TYPE_STRING and option["next"].begins_with("=>"):
				if TRACKING: print("func process_option(): Jumping to title: " + option["next"].substr(2).strip_edges())
				jump_to_title(option["next"].substr(2).strip_edges())
			else:
				if TRACKING: print("func process_option(): Adding to queue: " + str(option["next"]))
				dialogue_queue.push_front(option["next"])
				process_next_in_queue()
		else:
			if TRACKING: print("func process_option(): No next action, ending dialogue")
			end_dialogue()
		if TRACKING: print("func process_option(): Ending function")
	
	func end_dialogue():
		if TRACKING: print("func end_dialogue(): Ending dialogue")
		emit_signal("dialogue_ended")
		dialogue_queue.clear()
		current_title = ""
