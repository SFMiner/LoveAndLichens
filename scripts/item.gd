class_name Item
extends StaticBody2D

@export var item_name : String
	# The name of the item (examples: "Mana potion", "Iron sword")

@export var sprite_sheet : String
	# filename of the spritesheet to use for the texture

@export var frame_index : int = 0
	# The frame on the spreadsheet to use for the Item texture

@export var texture : Texture2D
	# The actual texture object of the loaded spritesheet

@export var texture_region : AtlasTexture
	#  the region of the texture to display on the TextureRect for the item.

@export var size : Vector2 = Vector2(32, 32)
	# The size of the region (it is assumed that all sprites on the spritesheet are of uniform size)  

@onready var texture_rect = $TextureRect

# Called when the node enters the scene tree for the first time.
var project_debug
var local_debug = true
var script_debug

func _ready() -> void:
	project_debug = GameState.debugging
	script_debug = project_debug and local_debug
	if not self.is_in_group("Collectible"):
		add_to_group("Collectible")
		if script_debug: print(GameState.script_name(self),  ": _ready(): added to Collectible.")
	else:
		if script_debug: print(GameState.script_name(self),  ": _ready(): is alraedy in Collectible.")
	if item_name:
		var old_name = name
		name = item_name
		if script_debug: print(GameState.script_name(self),  ": _ready(): ", old_name, " has been renamed to ", name, ".")
	set_texture()


func set_texture():
	# Load the texture
	texture = load("res://textures/" + sprite_sheet + ".png")
	if not texture:
		push_error("Failed to load texture: " + sprite_sheet)
		return

	# Calculate frame position
	var frame_width = int(size.x)
	var frame_height = int(size.y)
	var columns = texture.get_width() / frame_width
	var row = frame_index / int(columns)
	var col = frame_index % int(columns)
	
	var start_x = col * frame_width
	var start_y = row * frame_height

	# Create AtlasTexture
	texture_region = AtlasTexture.new()
	texture_region.atlas = texture
	texture_region.region = Rect2(start_x, start_y, frame_width, frame_height)

	# Assign texture_region to texture_rect
	if texture_rect:
		texture_rect.texture = texture_region
	else:
		push_error("TextureRect node not found in Item scene")
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
