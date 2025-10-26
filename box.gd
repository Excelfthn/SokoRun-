extends CharacterBody2D

# This MUST match your player's tile_size
const tile_size: Vector2 = Vector2(16, 16)
var sprite_node_pos_tween: Tween

# Get references to the box's own nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var up_ray: RayCast2D = $up
@onready var down_ray: RayCast2D = $down
@onready var left_ray: RayCast2D = $left
@onready var right_ray: RayCast2D = $right

func _ready():
##	# Add this node to the "Box" group so the player can identify it
	add_to_group("Box")

## This is the function the Player will call.
## It returns 'true' if the box successfully moved, and 'false' if it was blocked.
func push(dir: Vector2) -> bool:
	# Check if the box itself is blocked by a wall
	if not can_move(dir):
		return false
	
	# If it's not blocked, move the box
	_move(dir)
	return true

# Helper function to check the box's own raycasts
func can_move(dir: Vector2) -> bool:
	# Force rays to update so the check is immediate
	up_ray.force_raycast_update()
	down_ray.force_raycast_update()
	left_ray.force_raycast_update()
	right_ray.force_raycast_update()
	
	if dir == Vector2(0, -1): # Up
		return not up_ray.is_colliding()
	elif dir == Vector2(0, 1): # Down
		return not down_ray.is_colliding()
	elif dir == Vector2(-1, 0): # Left
		return not left_ray.is_colliding()
	elif dir == Vector2(1, 0): # Right
		return not right_ray.is_colliding()
	
	# Default case
	return false

# This is the exact same movement + tween logic from your player script
func _move(dir: Vector2):
	global_position += dir * tile_size
	sprite.global_position -= dir * tile_size
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
		
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(sprite, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)
