extends Control

class_name UI

@onready var inventory = $Inventory

signal item_used(item_data)

func _ready():
	inventory.connect("item_used", Callable(self, "_on_inventory_item_used"))

func _on_inventory_item_used(item_data):
	emit_signal("item_used", item_data)

func add_item_to_inventory(item):
	return inventory.add_item(item)

func remove_item_from_inventory(item_name):
	return inventory.remove_item(item_name)

func toggle_inventory():
	inventory.toggle_visibility()
