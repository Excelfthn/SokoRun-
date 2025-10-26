# Enemy.gd — grid-based MANUAL A* chaser
class_name Enemy
extends Node2D

signal player_captured

@export var step_interval: float = 0.5
@export var capture_range_cells: int = 1
@export_node_path var player_path: NodePath
@export_node_path var tilemap_layer_path: NodePath

@onready var player: Node2D = get_node(player_path)
@onready var layer: TileMapLayer = get_node(tilemap_layer_path)

# This dictionary will store our "map" of walls and obstacles.
# We store it as { Vector2i: bool }
var _solid_cells := {}

# The 4 directions for grid-based movement
const DIRS := [
	Vector2i(0, -1), # Up
	Vector2i(0, 1),  # Down
	Vector2i(-1, 0), # Left
	Vector2i(1, 0)   # Right
]

var enemy_cell: Vector2i
var _accum := 0.0

func _ready():
	var tile_size = 16
	global_position = Vector2(
		floor(global_position.x / tile_size) * tile_size + tile_size / 2,
		floor(global_position.y / tile_size) * tile_size + tile_size / 2
	)
	add_to_group("Enemy")
	
	_bake_walls_from_layer()

	enemy_cell = _world_to_cell(global_position)
	global_position = _cell_center_world(enemy_cell)
	print("[ENEMY] start cell=", enemy_cell, " solid=", _solid_cells.has(enemy_cell))


func _process(delta: float) -> void:
	_accum += delta
	if _accum >= step_interval:
		_accum = 0.0
		_step_towards_player()


func _step_towards_player() -> void:
	_bake_walls_from_layer()
	
	var player_cell := _world_to_cell(player.global_position)

	var used_rect := layer.get_used_rect()
	if not used_rect.has_point(enemy_cell) or not used_rect.has_point(player_cell):
		print("[ENEMY] out of region. enemy=", enemy_cell, " player=", player_cell)
		return

	if _solid_cells.has(enemy_cell):
		print("[ENEMY] enemy_cell is solid (on a wall).", enemy_cell)
		return

	if _is_captured(enemy_cell, player_cell):
		emit_signal("player_captured")
		return

	var path: Array = _find_path_manual_a_star(enemy_cell, player_cell)
	
	print("[ENEMY] Manual A* path size=", path.size(), " from ", enemy_cell, " to ", player_cell)

	if path.size() >= 2:
		var nxt: Vector2i = path[1]

		print("[ENEMY] step -> cell", nxt, " solid?", _solid_cells.has(nxt))
		enemy_cell = nxt
		global_position = _cell_center_world(enemy_cell)

		if _is_captured(enemy_cell, player_cell):
			emit_signal("player_captured")

func _bake_walls_from_layer() -> void:
	_solid_cells.clear()
	var r: Rect2i = layer.get_used_rect()

	# --- 1. Mark walls (tiles with collisions) ---
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			var c := Vector2i(x, y)
			var data: TileData = layer.get_cell_tile_data(c)

			var is_wall := false
			if data != null:
				var layer_idx := 0
				var poly_count: int = data.get_collision_polygons_count(layer_idx)
				for i in range(poly_count):
					var poly: PackedVector2Array = data.get_collision_polygon_points(layer_idx, i)
					if poly.size() > 0:
						is_wall = true
						break
			
			if is_wall:
				_solid_cells[c] = true

	# --- 2. Mark boxes as dynamic obstacles ---
	for box in get_tree().get_nodes_in_group("Box"):
		var box_cell := _world_to_cell(box.global_position)
		if r.has_point(box_cell):
			_solid_cells[box_cell] = true # Add boxes to the map


func _world_to_cell(world_pos: Vector2) -> Vector2i:
	var local: Vector2 = layer.to_local(world_pos)
	return layer.local_to_map(local)

func _cell_center_world(cell: Vector2i) -> Vector2:
	var local_center: Vector2 = layer.map_to_local(cell)
	return layer.to_global(local_center)

func _is_captured(e: Vector2i, p: Vector2i) -> bool:
	var d := e - p
	return abs(d.x) + abs(d.y) <= capture_range_cells


# ============================================================
#
# A* IMPLEMENTATION
#
# ============================================================

func _get_heuristic(cell_a: Vector2i, cell_b: Vector2i) -> int:
	return abs(cell_a.x - cell_b.x) + abs(cell_a.y - cell_b.y)


func _reconstruct_path(came_from: Dictionary, end_cell: Vector2i) -> Array:
	var path: Array = []
	var current = end_cell
	while current != null:
		path.push_front(current)
		current = came_from.get(current)
	return path


func _find_path_manual_a_star(start_cell: Vector2i, end_cell: Vector2i) -> Array:
	
	var open_list: Array = []

	var closed_list: Dictionary = {}

	var g_costs: Dictionary = {}
	
	var came_from: Dictionary = {}

	g_costs[start_cell] = 0
	var h_cost_start = _get_heuristic(start_cell, end_cell)
	var f_cost_start = g_costs[start_cell] + h_cost_start
	open_list.append({ "cell": start_cell, "f_cost": f_cost_start })
	came_from[start_cell] = null

	while not open_list.is_empty():
		
		open_list.sort_custom(func(a, b): return a.f_cost < b.f_cost)
		var current_node = open_list.pop_front()
		var current_cell: Vector2i = current_node.cell

		if current_cell == end_cell:
			return _reconstruct_path(came_from, end_cell)

		closed_list[current_cell] = true

		for dir in DIRS:
			var neighbor_cell: Vector2i = current_cell + dir
			
			if closed_list.has(neighbor_cell):
				continue
				
			if _solid_cells.has(neighbor_cell):
				continue
			
			var tentative_g_cost = g_costs.get(current_cell, 0) + 1

			
			var is_new_path = not g_costs.has(neighbor_cell)
			if is_new_path or tentative_g_cost < g_costs[neighbor_cell]:
				
				g_costs[neighbor_cell] = tentative_g_cost
				came_from[neighbor_cell] = current_cell

				var h_cost = _get_heuristic(neighbor_cell, end_cell)
				
				var f_cost = tentative_g_cost + h_cost

				if not _is_cell_in_list(open_list, neighbor_cell):
					open_list.append({ "cell": neighbor_cell, "f_cost": f_cost })

	return []


func _is_cell_in_list(list: Array, cell: Vector2i) -> bool:
	for item in list:
		if item.cell == cell:
			return true
	return false
