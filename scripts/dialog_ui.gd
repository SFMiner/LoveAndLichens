extends Control

signal continue_pressed
signal option_selected(option)

var speaker_label: Label
var text_label: Label
var continue_button: Button
var options_container: VBoxContainer
var is_ready: bool = false

func _init():
	print("dialog_ui._init() called")

func _enter_tree():
	print("dialog_ui._enter_tree() called")

func _ready():
	print("dialog_ui._ready() called")
	speaker_label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
	text_label = $Panel/MarginContainer/VBoxContainer/TextLabel
	continue_button = $Panel/MarginContainer/VBoxContainer/ContinueButton
	options_container = $Panel/MarginContainer/VBoxContainer/OptionsContainer
	
	if continue_button:
		continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))
	else:
		push_error("Continue button not found in Dialog UI")
	
	# Connect to visibility changed signal
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))
	
	visible = false  # Start hidden
	is_ready = true
	print("dialog_ui._ready() completed. Initial visibility: ", visible)

func _on_visibility_changed():
	print("dialog_ui visibility changed to: ", visible)

func ensure_ready():
	if not is_ready:
		print("dialog_ui.ensure_ready() calling _ready()")
		_ready()

func set_speaker(speaker: String):
	print("dialog_ui.set_speaker() called with: ", speaker)
	ensure_ready()
	if speaker_label:
		speaker_label.text = speaker
		speaker_label.visible = not speaker.is_empty()
	else:
		push_error("Speaker label not found in Dialog UI")

func set_text(new_text: String):
	print("dialog_ui.set_text() called with: ", new_text)
	ensure_ready()
	if text_label:
		text_label.text = new_text
	else:
		push_error("Text label not found in Dialog UI")

func show_continue_button():
	print("dialog_ui.show_continue_button() called")
	ensure_ready()
	if continue_button and options_container:
		continue_button.show()
		options_container.hide()
		visible = true  # Make sure the entire UI is visible
		print("dialog_ui visibility after show_continue_button: ", visible)
	else:
		push_error("Continue button or options container not found in Dialog UI")

func show_options(options: Array):
	print("dialog_ui.show_options() called with ", options.size(), " options")
	ensure_ready()
	if continue_button and options_container:
		continue_button.hide()
		
		# Clear existing options
		for child in options_container.get_children():
			child.queue_free()
		
		for option in options:
			var button = Button.new()
			button.text = option.text
			if option.has("character"):
				button.text = option.character + ": " + button.text
			button.connect("pressed", Callable(self, "_on_option_selected").bind(option))
			options_container.add_child(button)
		
		options_container.show()
		visible = true
		print("dialog_ui visibility after show_options: ", visible)
	else:
		push_error("Continue button or options container not found in Dialog UI")

func _on_continue_pressed():
	print("dialog_ui continue button pressed")
	emit_signal("continue_pressed")

func _on_option_selected(option):
	print("dialog_ui option selected: ", option.text)
	emit_signal("option_selected", option)

func set_character_style(color: Color, font: Font):
	ensure_ready()
	if text_label:
		var style_box = $Panel.get_theme_stylebox("panel").duplicate()
		style_box.bg_color = color
		$Panel.add_theme_stylebox_override("panel", style_box)
		text_label.add_theme_font_override("font", font)
	else:
		push_error("Text label not found in Dialog UI")
