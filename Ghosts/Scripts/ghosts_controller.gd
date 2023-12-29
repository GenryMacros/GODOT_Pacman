extends Node3D

enum {
	SPAWN_PHASE = 0,
	SCATTER_PHASE = 1,
	CHASE_PHASE = 2,
	FRIGHT_PHASE = 3
}

var current_phase = SPAWN_PHASE
var pre_fright_phase = current_phase
var spawn_timeouts: Array[float] = [
	ProjectSettings.get_setting("Ghosts/red_spawn_timeout"),
	ProjectSettings.get_setting("Ghosts/pink_spawn_timeout"),
	ProjectSettings.get_setting("Ghosts/orange_spawn_timeout"),
	ProjectSettings.get_setting("Ghosts/turq_spawn_timeout")
]
var scatter_length: float = ProjectSettings.get_setting("Ghosts/scatter_length")
var chase_length: float = ProjectSettings.get_setting("Ghosts/chase_length")
var frigh_length: float = ProjectSettings.get_setting("Ghosts/fright_length")
var scatter_counts: int = ProjectSettings.get_setting("Ghosts/scatter_counts")

@onready var timer: Timer = $Timer
@onready var ghosts: Array[CharacterBody3D] = [
	$Reddie,
	$Pinkie,
	$Orangie,
	$Turq
]

var ghost_initial_positions: Array[Vector3] = []
var next_spawning_ghost = 0


func _ready():
	for ghost in ghosts:
		ghost_initial_positions.append(ghost.position)
	timer.timeout.connect(_act)
	start_ghost_spawn()
	
	
func _act():
	timer.stop()
	if current_phase == SPAWN_PHASE:
		if next_spawning_ghost >= len(ghosts):
			current_phase = SCATTER_PHASE
			timer.wait_time = scatter_length
			timer.start()
			return
		ghosts[next_spawning_ghost].set_state(SCATTER_PHASE)
		print("%s Ghost %s is now active" % [Time.get_datetime_string_from_system(), ghosts[next_spawning_ghost].name])
		start_ghost_spawn()
		next_spawning_ghost += 1
	elif current_phase == SCATTER_PHASE:
		enter_chase()
	elif current_phase == CHASE_PHASE:
		if scatter_counts <= 0:
			return
		enter_scatter()
		scatter_counts -= 1
		print("%s Scatter rounds left: " % [Time.get_datetime_string_from_system(), scatter_counts])
	elif current_phase == FRIGHT_PHASE:
		timer.stop()
		current_phase = pre_fright_phase
		if current_phase == SCATTER_PHASE:
			enter_scatter()
		elif current_phase == CHASE_PHASE:
			enter_chase()
		else:
			for ghost in ghosts:
				if ghost.current_state != SPAWN_PHASE:
					ghost.set_state(SCATTER_PHASE)
			_act()
		
		
func start_ghost_spawn():
	timer.wait_time = spawn_timeouts[next_spawning_ghost]
	timer.start()


func enter_scatter():
	timer.stop()
	current_phase = SCATTER_PHASE
	timer.wait_time = scatter_length
	for ghost in ghosts:
		ghost.set_state(SCATTER_PHASE)
	print("%s Ghosts entered scatter mode" % [Time.get_datetime_string_from_system()])
	timer.start()


func enter_chase():
	timer.stop()
	current_phase = CHASE_PHASE
	timer.wait_time = chase_length
	for ghost in ghosts:
		ghost.set_state(CHASE_PHASE)
	print("%s Ghosts entered chase mode" % [Time.get_datetime_string_from_system()])
	timer.start()


func enter_fright():
	timer.stop()
	pre_fright_phase = current_phase
	current_phase = FRIGHT_PHASE
	timer.wait_time = frigh_length
	for ghost in ghosts:
		ghost.set_state(FRIGHT_PHASE)
	print("%s Ghosts entered frightened mode" % [Time.get_datetime_string_from_system()])
	timer.start()
	

func reset():
	timer.stop()
	current_phase = SPAWN_PHASE
	next_spawning_ghost = 0
	
	for i in range(len(ghosts)):
		ghosts[i].position = ghost_initial_positions[i]
		ghosts[i].set_state(SPAWN_PHASE)
	timer.wait_time = spawn_timeouts[0]
	timer.start()
	

func stop_ghosts():
	for ghost in ghosts:
		ghost.stop()
		
