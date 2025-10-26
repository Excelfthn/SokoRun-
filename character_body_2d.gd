extends CharacterBody2D

const tile_size: Vector2 = Vector2(16, 16)
var sprite_node_pos_tween: Tween

# Get references to RayCasts and Sprite
@onready var up_ray: RayCast2D = $up
@onready var down_ray: RayCast2D = $down
@onready var left_ray: RayCast2D = $left
@onready var right_ray: RayCast2D = $right
@onready var sprite: Sprite2D = $Sprite2D # Assuming it's named Sprite2D

func _ready():
	# Snap player to nearest tile center (matches the TileMap grid)
	var tile_size = 16
	global_position = Vector2(
		floor(global_position.x / tile_size) * tile_size + tile_size / 2,
		floor(global_position.y / tile_size) * tile_size + tile_size / 2
	)

func _physics_process(_delta: float) -> void:
	# Check for input one by one
	if Input.is_action_just_pressed("ui_up"):
		_try_move(Vector2(0, -1), up_ray)
	elif Input.is_action_just_pressed("ui_down"):
		_try_move(Vector2(0, 1), down_ray)
	elif Input.is_action_just_pressed("ui_left"):
		_try_move(Vector2(-1, 0), left_ray)
	elif Input.is_action_just_pressed("ui_right"):
		_try_move(Vector2(1, 0), right_ray)

# New function to handle the movement and pushing logic
func _try_move(dir: Vector2, ray: RayCast2D):
	# Force the raycast to update its collision info immediately
	ray.force_raycast_update()
	
	var collider = ray.get_collider()
	
	if collider == null:
		# 1. Nothing is in the way. Just move.
		_move(dir)
		
	elif collider.is_in_group("Box"):
		# 2. It's a box! Try to push it.
		# We check 'has_method' just to be safe.
		if collider.has_method("push"):
			# Call the box's push() function and store the result
			var box_moved: bool = collider.push(dir)
			
			# If the box successfully moved, we can move into its old spot
			if box_moved:
				_move(dir)
				
	# 3. Else: It's a wall or other object. Do nothing.

# This function is identical to your original
func _move(dir: Vector2):
	global_position += dir * tile_size
	# Use the @onready var 'sprite' instead of $Sprite2D
	sprite.global_position -= dir * tile_size 
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	# Use the @onready var 'sprite'
	sprite_node_pos_tween.tween_property(sprite, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)
