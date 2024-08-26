extends Node2D

var dialog_parser = DialogParser.new()
var dialog_data 

# Called when the node enters the scene tree for the first time.
var project_debug
var local_debug = true
var script_debug

func _ready() -> void:
	project_debug = GameState.debugging
	script_debug = project_debug and local_debug
#	dialog_parser._ready()
	dialog_data = dialog_parser.parse_dialog_file("res://dialogues/test.dialogue.txt")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("start_dialogue"):
		start_dialog()

func start_dialog():
	GameState.get_main().dialog_manager.start_dialog(dialog_data)
