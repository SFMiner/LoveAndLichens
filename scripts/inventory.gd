extends Control

class_name Inventory

@export var slots : int = 20
@export var slot_size : Vector2 = Vector2(64, 64)
@export var grid_columns : int = 5

var items : Array = []
@onready var grid_container : GridContainer = $GridContainer
@onready var panel : Panel = $Panel

signal item_used(item_data)

var project_debug
var local_debug = true
var script_debug

func _ready():
	project_debug = GameState.debugging
	script_debug = project_debug and local_debug
	setup_inventory_ui()
	resize_panel()
	self.visible = false
	
func setup_inventory_ui():
	grid_container.columns = 5  # Adjust this value to change the number of columns
	for i in range(slots):
		var slot = TextureRect.new()
		slot.expand = true
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.custom_minimum_size = slot_size
		slot.texture = load("res://textures/inventory_slot.png")  # Replace with your slot background texture
		slot.connect("gui_input", Callable(self, "_on_slot_gui_input").bind(i))
		grid_container.add_child(slot)

func resize_panel():
	var panel_width = ((slot_size[0] + 4) * grid_columns) + 8
	var panel_height = ((slot_size[0] + 4) * slots/grid_columns) + 8
	panel.position = grid_container.position - Vector2(6,6)
	panel.size = Vector2(panel_width, panel_height)

func add_item(item : Item):
	if items.size() < slots:
		var item_data = {
			"name": item.item_name,
			"texture_region": item.texture_region
			# Add any other relevant item data here
		}
		items.append(item_data)
		update_inventory_display()
		return true
	return false

func remove_item(item_name : String):
	for i in range(items.size()):
		if items[i]["name"] == item_name:
			items.remove_at(i)
			update_inventory_display()
			return true
	return false

func update_inventory_display():
	for i in range(slots):
		var slot = grid_container.get_child(i)
		if i < items.size():
			slot.texture = items[i]["texture_region"]
		else:
			slot.texture = load("res://textures/inventory_slot.png")  # Replace with your slot background texture

func _on_slot_gui_input(event : InputEvent, slot_index : int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if slot_index < items.size():
			emit_signal("item_used", items[slot_index])

func toggle_visibility():
	visible = !visible
