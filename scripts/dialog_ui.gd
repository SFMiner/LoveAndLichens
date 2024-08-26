extends Control

var project_debug
var local_debug = true
var script_debug

signal continue_pressed
signal option_selected(option)

var speaker_label: Label
var text_label: Label
var continue_button: Button
var options_container: VBoxContainer
var is_ready: bool = false

func _init():
	project_debug = GameState.debugging
	script_debug = project_debug and local_debug
	if script_debug: print(GameState.script_name(self), ":_init() - Initializing DialogUI")

func _ready():
	if script_debug: print(GameState.script_name(self), ":_ready() - Setting up DialogUI")
	speaker_label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
	text_label = $Panel/MarginContainer/VBoxContainer/TextLabel
	continue_button = $Panel/MarginContainer/VBoxContainer/ContinueButton
	options_container = $Panel/MarginContainer/VBoxContainer/OptionsContainer
	
	if continue_button:
		continue_button.connect("pressed", Callable(self, "_on_continue_pressed"))
	else:
		if script_debug: print(GameState.script_name(self), ":_ready() - Continue button not found in Dialog UI")
		push_error("Continue button not found in Dialog UI")
	
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))
	
	visible = false  # Start hidden
	is_ready = true
	if script_debug: print(GameState.script_name(self), ":_ready() - DialogUI setup complete. Initial visibility: ", visible)

func _on_visibility_changed():
	if script_debug: print(GameState.script_name(self), ":_on_visibility_changed() - DialogUI visibility changed to: ", visible)

func ensure_ready():
	if not is_ready:
		if script_debug: print(GameState.script_name(self), ":ensure_ready() - Calling _ready()")
		_ready()

func set_speaker(speaker: String):
	if script_debug: print(GameState.script_name(self), ":set_speaker() - Setting speaker to: ", speaker)
	ensure_ready()
	if speaker_label:
		speaker_label.text = speaker
		speaker_label.visible = not speaker.is_empty()
	else:
		if script_debug: print(GameState.script_name(self), ":set_speaker() - Speaker label not found")
		push_error("Speaker label not found in Dialog UI")

func set_text(new_text: String):
	if script_debug: print(GameState.script_name(self), ":set_text() - Setting text to: ", new_text)
	ensure_ready()
	if text_label:
		text_label.text = new_text
	else:
		if script_debug: print(GameState.script_name(self), ":set_text() - Text label not found")
		push_error("Text label not found in Dialog UI")

func show_continue_button():
	if script_debug: print(GameState.script_name(self), ":show_continue_button() - Showing continue button")
	ensure_ready()
	if continue_button and options_container:
		continue_button.show()
		options_container.hide()
		visible = true
		if script_debug: print(GameState.script_name(self), ":show_continue_button() - DialogUI visibility: ", visible)
	else:
		if script_debug: print(GameState.script_name(self), ":show_continue_button() - Continue button or options container not found")
		push_error("Continue button or options container not found in Dialog UI")

func show_options(options: Array):
	if script_debug: print(GameState.script_name(self), ":show_options() - Showing options: ", options)
	ensure_ready()
	if continue_button and options_container:
		continue_button.hide()
		
		# Clear existing options
		for child in options_container.get_children():
			child.queue_free()
		
		for option in options:
			var button = Button.new()
			button.text = option.text
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.connect("pressed", Callable(self, "_on_option_selected").bind(option))
			options_container.add_child(button)
			if script_debug: print(GameState.script_name(self), ":show_options() - Created button with text: ", button.text)
		
		options_container.show()
		visible = true
		if script_debug: print(GameState.script_name(self), ":show_options() - DialogUI visibility: ", visible)
		if script_debug: print(GameState.script_name(self), ":show_options() - Number of option buttons created: ", options_container.get_child_count())
	else:
		if script_debug: print(GameState.script_name(self), ":show_options() - Continue button or options container not found")
		push_error("Continue button or options container not found in Dialog UI")

func _on_continue_pressed():
	if script_debug: print(GameState.script_name(self), ":_on_continue_pressed() - Continue button pressed")
	emit_signal("continue_pressed")

func _on_option_selected(option):
	if script_debug: print(GameState.script_name(self), ":_on_option_selected() - Option selected: ", option)
	emit_signal("option_selected", option)
