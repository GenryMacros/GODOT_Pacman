extends "res://Ghosts/Scripts/ghost_automata.gd"


var circle_radius = 16


func _ready():
	super._ready()
	timer.timeout.connect(correct_path)
	
	
func setup_chase_movement():
	correct_path()
	timer.wait_time = 0.5
	timer.start()
	
	
func correct_path():
	super.correct_path()
	
	var player_dir: Vector3 = player.position
	if player_dir.distance_to(position) > circle_radius:
		nav_agent.target_position = player.position
	else:
		nav_agent.target_position = scatter_targets[0].position
