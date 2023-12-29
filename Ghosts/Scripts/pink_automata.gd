extends "res://Ghosts/Scripts/ghost_automata.gd"


var middle_tile_distance = 8


func _ready():
	super._ready()
	timer.timeout.connect(correct_path)
	
	
func setup_chase_movement():
	correct_path()
	timer.wait_time = 0.5
	timer.start()
	
	
func correct_path():
	super.correct_path()
	var player_dir: Vector2 = player.last_input
	var direction = (transform.basis * Vector3(player_dir.y, 0, player_dir.x)).normalized()
	nav_agent.target_position = player.position + Vector3(middle_tile_distance, 0, middle_tile_distance) * Vector3(direction.x * -1, 0, direction.z)
