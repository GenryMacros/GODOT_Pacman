extends "res://Ghosts/Scripts/ghost_automata.gd"



func _ready():
	super._ready()
	timer.timeout.connect(correct_path)
	
	
func setup_chase_movement():
	correct_path()
	timer.wait_time = 0.1
	timer.start()
	
	
func correct_path():
	super.correct_path()
	nav_agent.target_position = player.position
