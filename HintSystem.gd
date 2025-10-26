extends Node2D

@export var tile_size: Vector2 = Vector2(16, 16)
@export_node_path var player_path: NodePath
@export_node_path var tilemap_layer_path: NodePath  # your TileMapLayer with wall tiles

@onready var player: CharacterBody2D = get_node(player_path)
@onready var tilemap_layer: TileMapLayer = get_node(tilemap_layer_path)

const DIRS := [
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(1, 0)
]

var path_to_draw: Array = []
var _search_rect: Rect2i = Rect2i()
var path_points: Array = []
var path_alpha: float = 1.0
var fade_timer: Timer


# ------------------------------------------------------------
# Input and drawing
# ------------------------------------------------------------
func _input(event):
	if event.is_action_pressed("hint"):  # press "H" (define it in Input Map)
		show_hint()

func show_hint() -> void:
	if not path_points.is_empty():
		# already showing → toggle off
		path_points.clear()
		queue_redraw()
		print("Hint hidden.")
		return

	path_points = find_shortest_path_to_nearest_box()
	if path_points.is_empty():
		print("No path found.")
		return

	print("Path found:", path_points.size(), "points:", path_points)
	path_alpha = 1.0
	queue_redraw()


func _draw() -> void:
	if path_points.is_empty():
		return

	var color := Color(1, 1, 0, path_alpha)  # yellow with transparency
	for i in range(path_points.size() - 1):
		draw_line(path_points[i], path_points[i + 1], color, 2.0)


# ------------------------------------------------------------
# BFS pathfinding logic
# ------------------------------------------------------------
func find_shortest_path_to_nearest_box() -> Array:
	var start_cell := world_to_cell(player.global_position)
	print("Player cell:", start_cell)

	# Cache all box tile positions
	var box_cells := {}
	for box in get_tree().get_nodes_in_group("Box"):
		var bc := world_to_cell(box.global_position)
		box_cells[bc] = box
		print("Box cell:", bc)

	# Build a search rect that includes used tiles, player and boxes (with padding)
	_build_search_rect(start_cell, box_cells)

	# BFS
	var queue := [start_cell]
	var came_from := {}
	came_from[start_cell] = null

	while queue.size() > 0:
		var current: Vector2i = queue.pop_front()

		# Found a box
		if box_cells.has(current):
			var tile_path := _reconstruct_path(came_from, current)
			return _tile_path_to_world_centers(tile_path)

		for d in DIRS:
			var next_cell: Vector2i = current + d
			if came_from.has(next_cell):
				continue
			if _is_cell_blocked(next_cell):
				continue
			came_from[next_cell] = current
			queue.append(next_cell)

	# nothing found
	return []



# ------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------
func _reconstruct_path(came_from: Dictionary, end_cell: Vector2i) -> Array:
	var path: Array = []
	var cur = end_cell  # don't type this as Vector2i!
	while cur != null:
		path.push_front(cur)
		cur = came_from.get(cur, null)
	return path

# --- Coordinate conversion helpers ---
func world_to_cell(world_pos: Vector2) -> Vector2i:
	# Converts a world position into a TileMapLayer grid cell.
	var local_pos = tilemap_layer.to_local(world_pos)
	var cell = tilemap_layer.local_to_map(local_pos)
	return cell

func cell_to_world_center(cell: Vector2i) -> Vector2:
	var local_pos = tilemap_layer.map_to_local(cell)
	var world_pos = tilemap_layer.to_global(local_pos)
	return world_pos + tilemap_layer.tile_set.tile_size / 2.0 + Vector2(0, -1)


func _tile_path_to_world_centers(tile_path: Array) -> Array:
	var out := []
	for cell in tile_path:
		out.append(cell_to_world_center(cell))
	return out

func _build_search_rect(start_cell: Vector2i, box_cells: Dictionary) -> void:
	# Start with the TileMapLayer used rect
	var used := tilemap_layer.get_used_rect()  # Rect2i
	var min_x := used.position.x
	var min_y := used.position.y
	var max_x := used.position.x + used.size.x - 1
	var max_y := used.position.y + used.size.y - 1

	# include start cell
	min_x = min(min_x, start_cell.x)
	min_y = min(min_y, start_cell.y)
	max_x = max(max_x, start_cell.x)
	max_y = max(max_y, start_cell.y)

	# include all box cells
	for cell in box_cells.keys():
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)

	# add a small padding so BFS can explore around targets
	var padding := 6
	min_x -= padding
	min_y -= padding
	max_x += padding
	max_y += padding

	# build Rect2i (position, size)
	var width := max_x - min_x + 1
	var height := max_y - min_y + 1
	_search_rect = Rect2i(Vector2i(min_x, min_y), Vector2i(width, height))
	print("Search rect:", _search_rect)

# ------------------------------------------------------------
# Collision check (simplified – assumes all wall tiles block)
# ------------------------------------------------------------

func _is_cell_blocked(cell: Vector2i) -> bool:
	# 1. Out of bounds
	if not _search_rect.has_point(cell):
		return true

	# 2. Check for wall collisions
	var data: TileData = tilemap_layer.get_cell_tile_data(cell)
	if data != null:
		var layer_idx := 0  # Most tilesets only use physics layer 0
		var poly_count: int = data.get_collision_polygons_count(layer_idx)
		for i in range(poly_count):
			var poly: PackedVector2Array = data.get_collision_polygon_points(layer_idx, i)
			if poly.size() > 0:
				return true  # tile has a collision shape → wall

	# 3. Check if a box occupies this cell
	for box in get_tree().get_nodes_in_group("Box"):
		var box_cell := world_to_cell(box.global_position)
		if cell == box_cell:
			return false  # allow pathfinding onto the target box

	return false
