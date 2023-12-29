extends GridMap


@export var score_eatable: PackedScene
@export var power_eatable: PackedScene
@export var power_markers: Array[Marker3D]

var detection_area: Area3D
var ghost_house_area: Area3D

var map_width: int = 0
var map_height: int = 0
var points_count = 0
var left_most_coords: Vector3i = Vector3i()
var player_coords: Vector3 = Vector3()
var is_initialized = false


func _ready():
	detection_area = $player_detection_area
	ghost_house_area = $ghosts_house_area
	
	var items = get_used_cells()
	left_most_coords = items[0]
	player_coords = left_most_coords + Vector3i(-1, 0, -1)
	
	var min_x: int = left_most_coords.x
	var max_z: int = left_most_coords.z
	for item in items:
		min_x = min(min_x, item.x)
		max_z = max(max_z, item.z)
	
	map_width = max_z - left_most_coords.z
	map_height = left_most_coords.x - min_x
	
	reset_score_eatables()
	
	
func reset_score_eatables():
	remove_all_eatables()
	points_count = 0
	for x in range(left_most_coords.x, left_most_coords.x - map_height, -1):
		for z in range(left_most_coords.z, map_width + left_most_coords.z):
			var cell_pos = Vector3i(x, 0, z)
			var cell: int = get_cell_item(cell_pos)
			if cell == INVALID_CELL_ITEM:
				place_score_eatable(cell_pos)


func remove_all_eatables():
	for node in self.get_children():
		if node.name.begins_with("eatable"):
			node.queue_free()
		
		
func place_score_eatable(cell: Vector3i):
	
	if is_player_at_position(Vector3(cell)):
		return
	
	var pos = get_map_node_position(Vector3(cell))
	var node: Node3D
	
	if is_power_position(pos):
		node = power_eatable.instantiate()
	else:
		node = score_eatable.instantiate()
		points_count += 1
	
	node.position = pos	
	node.name = node.name + str(len(self.get_children()))
	add_child(node)
	
	
func is_player_at_position(coords: Vector3) -> bool:
	if coords == player_coords:
		return true

	detection_area.position = get_map_node_position(coords)
	var overlapped = detection_area.get_overlapping_bodies()
	for overlap in overlapped:
		if overlap.name == "Player":
			return true
	return false


func is_power_position(world_position: Vector3) -> bool:
	for pm in power_markers:
		if pm.position.distance_to(world_position) <= 1:
			return true
	return false
		
	
func get_map_node_position(coords: Vector3):
	return map_to_local(coords) * (cell_size / 2) 
