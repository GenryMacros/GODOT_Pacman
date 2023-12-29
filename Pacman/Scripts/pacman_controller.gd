extends CharacterBody3D

signal eatable_consumed(eatable_worth: float)
signal power_consumed
signal damage_taken


@export var this_area: Area3D
var is_stopped = false
var body_3d: Node3D = null
var start_position: Vector3
const SPEED = 5.0


var eatables_worth = {
	"eatable_score_default": ProjectSettings.get_setting("Score/eatable_score_default"),
	"eatable_power_default": ProjectSettings.get_setting("Score/eatable_power_default")
}

var gravity = ProjectSettings.get_setting("Environment/gravity_pacman")
var last_input = Vector2(0.0, 0.0)
var last_position: Vector3 = position


func _ready():
	body_3d = $pacman
	this_area.area_entered.connect(_handle_area_enter)
	start_position = self.position
	
	
func _handle_area_enter(area: Area3D):
	if area.name.begins_with("Score_Eatable_Area"):
		eatable_consumed.emit(eatables_worth["eatable_score_default"])
	elif area.name.begins_with("Power_Eatable_Area"):
		eatable_consumed.emit(eatables_worth["eatable_power_default"])
		power_consumed.emit()
		
		
func _physics_process(_delta):
	if is_stopped:
		return
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.y != 0 or input_dir.x != 0:
		if input_dir.x != 0 and input_dir.y != 0:
			input_dir.x = 0
		last_input = input_dir
		change_rotation_according2input()
		
	var direction = (transform.basis * Vector3(last_input.y, 0, last_input.x)).normalized()
	
	if direction:
		velocity.x = direction.x * -SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	var pos_diff = abs(position - last_position)
	if pos_diff.x > 0.01 or pos_diff.z > 0.01:
		last_position = position
		$pacman/AnimationPlayer.play("Eat")
	else:
		$pacman/AnimationPlayer.stop()
		
		
func change_rotation_according2input():
	if last_input.x == 0 and last_input.y > 0:
		body_3d.rotation_degrees = Vector3(0, 90, 90)
	elif last_input.x > 0 and last_input.y == 0:
		body_3d.rotation_degrees = Vector3(0, 180, 90)
	elif last_input.x == 0 and last_input.y < 0:
		body_3d.rotation_degrees = Vector3(0, -90, 90)
	elif last_input.x < 0 and last_input.y == 0:
		body_3d.rotation_degrees = Vector3(180, 180, 90)
	

func reset():
	last_input = Vector2.ZERO
	body_3d.rotation_degrees = Vector3(0, 180, 90)
	position = start_position
	
	
func take_damage():
	damage_taken.emit()


func stop():
	is_stopped = !is_stopped
	

func to_game_over():
	stop()
		
