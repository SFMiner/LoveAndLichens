extends CharacterBody2D  # Assuming this is a CharacterBody2D

@export var NPC_mode: bool = false
@export var movement_speed: float = 200.0
@onready var anim = $anim  # Adjust this to match your node structure
@onready var raycast = $RayCast2D  # Adjust this to match your node structure
@export var relationships = []
@export var raycast_distance : int = 100
@onready var navigation_agent = $NavigationAgent2D  # Adjust this to match your node structure

var last_direction: String = "down"
var direction: String = "down"
var ui: UI

func _ready():
	# Find the UI node
	ui = get_tree().get_root().find_child("UI", true, false)
	if ui:
		ui.connect("item_used", Callable(self, "_on_item_used"))
	else:
		push_error("UI node not found")

func _physics_process(delta: float) -> void:
	if not NPC_mode:
		handle_player_input()
	else:
		handle_npc_movement()
	
	move_and_slide()
	z_index = global_position.y
	
	update_animation()
	
	
func handle_player_input():
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
#		print ("Go left")
		velocity.x -= 1
		direction = "left"
	elif Input.is_action_pressed("ui_right"):
#		print ("Go right")
		velocity.x += 1
		direction = "right"
	
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		direction = "up"
#		print ("Go up")
	elif Input.is_action_pressed("ui_down"):
		velocity.y += 1
		direction = "down"
#		print ("Go down")
	
	velocity = velocity.normalized() * movement_speed
	
	update_raycast()
	
	if Input.is_action_just_pressed("ui_interact"):
		interact_with_object()

func handle_npc_movement():
	if navigation_agent.is_navigation_finished():
		NPC_mode = false
		velocity = Vector2.ZERO
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed

func update_animation():
#	print(velocity)
	if velocity != Vector2.ZERO:
		var angle = atan2(velocity.y, velocity.x)
		var degrees = rad_to_deg(angle)
		if degrees < 0:
			degrees += 360
		
		var anim_direction = get_animation_direction(degrees)
		
		if anim_direction != "":
			anim.play("walk_" + anim_direction)
			last_direction = anim_direction
	else:
		stop_movement()
	
	if has_node("Label"):
		var label = $Label
		if label is Label:
			label.text = "idle" if velocity == Vector2.ZERO else last_direction

func get_animation_direction(degrees: float) -> String:
	if degrees < 22.5 or degrees >= 337.5:
		return "right"
	elif degrees < 67.5:
		return "down" #_right"
	elif degrees < 112.5:
		return "down"
	elif degrees < 157.5:
		return "down" #_left"
	elif degrees < 202.5:
		return "left"
	elif degrees < 247.5:
		return "left" #up_left"
	elif degrees < 292.5:
		return "up"
	else:
		return "right" #_right"

func stop_movement():
#	print("stop_movement(): last_direction = ", last_direction)
	velocity = Vector2.ZERO
	anim.stop()
	if last_direction != "":
		anim.play("idle_" + last_direction)
	else:
		anim.play("idle_down")  # Default idle animation

func update_raycast():
	match direction:
		"down":
			raycast.set_target_position(Vector2(0, raycast_distance))
		"up":
			raycast.set_target_position(Vector2(0, -raycast_distance))
		"left":
			raycast.set_target_position(Vector2(-raycast_distance/2, 0))
		"right":
			raycast.set_target_position(Vector2(raycast_distance/2, 0))
	raycast.enabled = true
	raycast.force_raycast_update()


func swap_characters(character):
	$sprite.set_texture(character)


func interact_with_object():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("interact"):
			collider.interact(self)
		elif collider.is_in_group("Collectible"):
			collect_item(collider)

func collect_item(item):
	if ui.add_item_to_inventory(item):
		print("Collected: ", item.item_name)
		item.queue_free()
	else:
		print("Inventory full, can't collect ", item.item_name)

func _on_item_used(item_data):
	print("Player used item: ", item_data["name"])
	# Implement item use effects here
	ui.remove_item_from_inventory(item_data["name"])
	# You can add more specific item use logic here

func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		ui.toggle_inventory()
		
func get_inventory():
	return GameState.inventory

func use_item(item_name):
	if GameState.remove_from_inventory(item_name):
		print("Used item: ", item_name)
		# Implement item use effects here
	else:
		print("Item not in inventory: ", item_name)

func update_relationship(character_name, value):
	GameState.update_relationship(character_name, value)
	print("Updated relationship with ", character_name, " by ", value)

func get_relationship(character_name):
	return GameState.get_relationship(character_name)

	
