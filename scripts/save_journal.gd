extends Control

@onready var entry_text = $Panel/VBoxContainer/mc/EntryText
@onready var filename_input = $Panel/VBoxContainer/HBoxContainer/mc/FilenameInput
@onready var btn_save = $Panel/VBoxContainer/HBoxContainer/mc/btn_Save
@onready var btn_cancel = $Panel/VBoxContainer/HBoxContainer2/mc/btn_Cancel


var current_filename = ""
var save_directory = "user://journal/"

signal entry_saved(filename)

func _ready():
	if not DirAccess.dir_exists_absolute(save_directory):
		DirAccess.make_dir_absolute(save_directory)

func set_entry(text: String, filename: String = ""):
	entry_text.text = text
	current_filename = filename
	filename_input.text = filename if filename else "new_entry.json"

func _on_btn_save_pressed() -> void:
	var filename = filename_input.text.strip_edges()
	if filename.is_empty():
		print("Please enter a filename")
		return
	
	if not filename.ends_with(".json"):
		filename += ".json"
	
	var file_path = save_directory + filename
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var save_data = {
			"text": entry_text.text,
			"date": Time.get_date_string_from_system()
		}
		file.store_string(JSON.stringify(save_data))
		print("Entry saved as: ", filename)
		emit_signal("entry_saved", filename)
		queue_free()
	else:
		print("Failed to save entry")


func _on_brn_cancel_pressed() -> void:
	queue_free()
