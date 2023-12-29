extends CharacterBody3D


enum {
	INACTIVE = 0,
	SCATTER = 1,
	CHASE = 2,
 	FRIGHTENED = 3,
	RETIRE = 4
}


var SPEED = ProjectSettings.get_setting("Ghosts/ghost_speed")

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var timer: Timer = $Timer
@onready var overlap_area: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $Body/AnimationPlayer

@export var scatter_targets: Array[Marker3D]
@export var player: CharacterBody3D

var revival_time = ProjectSettings.get_setting("Ghosts/revival_time")
var current_scatter_target: int = 0
var current_state = INACTIVE
var is_stopped = false
var is_dead = false

var random = RandomNumberGenerator.new()
var gravity = ProjectSettings.get_setting("Environment/gravity_pacman")
var current_dir: Vector3
var initial_location: Vector3


func _ready():
	nav_agent.target_reached.connect(switch_target)
	overlap_area.area_entered.connect(handle_area_enter)
	initial_location = self.position
	make_scatter_path()


func switch_target():
	current_scatter_target = current_scatter_target + 1 
	if current_scatter_target >= len(scatter_targets):
		current_scatter_target = 0
	make_scatter_path()
	

func handle_area_enter(other_area: Area3D):
	if other_area.name == "Player_Area":
		if current_state == FRIGHTENED:
			setup_retire_movement()
			style2dead()
		elif current_state == RETIRE:
			return
		else:
			player.take_damage()
		
		
func make_scatter_path():
	nav_agent.target_position = scatter_targets[current_scatter_target].position

	
func _physics_process(_delta):
	if current_state == INACTIVE or is_stopped:
		return
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	current_dir = dir
	if abs(current_dir.x) > abs(current_dir.y):
		current_dir.y = 0
	else:
		current_dir.x = 0
	velocity = current_dir * SPEED
	move_and_slide()
	move_eyes(Vector2(current_dir.x, current_dir.z))
	

func move_eyes(dir: Vector2):
	if (dir.y == 0 and abs(dir.x) < 0.3) or (dir.x == 0 and abs(dir.y) < 0.3):
		dir = Vector2.ZERO
	if abs(dir.x) > abs(dir.y):
		dir.y = 0
		dir = dir.normalized()
	else:
		dir.x = 0
		dir = dir.normalized()
		
	var key_ind = 0

	if dir == Vector2(1, 0):
		key_ind = 0
	elif dir == Vector2(0, 1):
		key_ind = 1
	elif dir == Vector2(-1, 0):
		key_ind = 2
	elif dir == Vector2(0, -1):
		key_ind = 4
	else:
		key_ind = 3
	
	var animation = animation_player.get_animation("Scene")
	animation_player.play("Scene")
	animation_player.seek(animation.track_get_key_time (0, key_ind), true)
	animation_player.stop(true)
	
	
func set_state(new_state: int):
	if is_dead:
		return
		
	if current_state == INACTIVE:
		if new_state != SCATTER:
			return
		$CollisionShape3D.disabled = true
	if current_state == FRIGHTENED and new_state != FRIGHTENED:
		style2normal()
		
	current_state = new_state
	if current_state == SCATTER:
		setup_scatter_movement()
	elif current_state == CHASE:
		setup_chase_movement()
	elif current_state == FRIGHTENED:
		setup_frightened_movement()	
		style2fright()
	elif current_state == INACTIVE:
		timer.stop()
		nav_agent.target_position = position
		$CollisionShape3D.disabled = false
		move_eyes(Vector2.ZERO)
		

func setup_scatter_movement():
	timer.stop()
	make_scatter_path()

	
func setup_frightened_movement():
	timer.stop()
	var turn_around_dir = current_dir * Vector3(-1, -1, -1)
	nav_agent.target_position = position + turn_around_dir * Vector3(8, 0, 8)

	timer.wait_time = 1
	timer.timeout.disconnect(correct_path)
	timer.timeout.connect(_frightened_update)
	timer.start()
	

func setup_retire_movement():
	print("%s Ghost %s is dead" % [Time.get_datetime_string_from_system(), self.name])
	timer.stop()
	is_dead = true
	nav_agent.target_position = initial_location
	timer.timeout.disconnect(_frightened_update)
	nav_agent.target_reached.disconnect(switch_target)
	nav_agent.target_reached.connect(start_revive)
	
	
func style2fright():
	$Body/RootNode.visible = false
	$Body/GhostFright.visible = true
	

func style2normal():
	if is_dead:
		print("%s Ghost %s has been resurrected" % [Time.get_datetime_string_from_system(), self.name])
		$Body/RootNode/ghost_body.get_active_material(0).transparency = 0
		timer.stop()
		is_dead = false
		SPEED /= 2
		current_state = SCATTER
		nav_agent.target_reached.connect(switch_target)
		make_scatter_path()
	else:
		$Body/RootNode.visible = true
		$Body/GhostFright.visible = false
	

func style2dead():
	SPEED *= 2
	$Body/RootNode.visible = true
	$Body/GhostFright.visible = false
	$Body/RootNode/ghost_body.get_active_material(0).transparency = 1
	
	
func start_revive():
	timer.stop()
	nav_agent.target_reached.disconnect(start_revive)
	timer.timeout.connect(style2normal)
	timer.wait_time = revival_time
	timer.start()
	
func _frightened_update():
	var random_num = random.randf()
	if random_num > 0.5:
		nav_agent.target_position = position + Vector3(1, 0, 0) * Vector3(8, 0, 8)
	else:
		nav_agent.target_position = position + Vector3(0, 0, 1) * Vector3(8, 0, 8)
	

func setup_chase_movement():
	pass


func correct_path():
	timer.stop()
	timer.wait_time = 0.5
	timer.timeout.disconnect(_frightened_update)
	timer.timeout.connect(correct_path)
	timer.start()
	

func stop():
	is_stopped = !is_stopped
	
