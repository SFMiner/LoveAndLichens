@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("DialogResource", "Resource", preload("res://scripts/dialog_resource.gd"), null)

func _exit_tree():
	remove_custom_type("DialogResource")
