extends Node3D


var pacman_health = ProjectSettings.get_setting("Environment/pacman_health")


@onready var player: CharacterBody3D = $Player
@onready var ghost_controller: Node3D = $Ghosts_Controller
@onready var grid: GridMap = $NavigationRegion3D/GridMap
@onready var shader_plane: MeshInstance3D = $Camera3D/ShaderPlane
@onready var timer: Timer = $Timer

var pixel_size = 2
var is_aliasing = true
var is_game_over = false


func _ready():
	player.eatable_consumed.connect($UserInterface/ScoreLabel._on_eatable_consume.bind())
	player.power_consumed.connect(ghost_controller.enter_fright.bind())
	player.damage_taken.connect(health_decrease)
	$UserInterface.to_game()

func start_reset():
	timer.stop()
	timer.wait_time = 0.03
	timer.start()
	timer.timeout.connect(process_pixelization)


func _on_eatable_consume(score_increment: float):
	$UserInterface/ScoreLabel._on_eatable_consume(score_increment)
	$NavigationRegion3D/GridMap.points_count -= 1
	if $NavigationRegion3D/GridMap.points_count <= 0:
		$UserInterface.to_gg()
		$Ghosts_Controller.stop_ghosts()
		player.to_game_over()
		$Player/pacman.visible = false
		$Light.set_param($Light.PARAM_ENERGY, 0.1)
		is_game_over = true
	

func stop_all_entities():
	player.stop()
	ghost_controller.stop_ghosts()
	
	
func process_pixelization():
	shader_plane.get_active_material(0).set("shader_param/pixel_size", pixel_size)
	if is_aliasing:
		pixel_size += 2
	else:
		pixel_size -= 2
	if pixel_size >= 30:
		is_aliasing = false
		stop_all_entities()
		reset()
	if pixel_size <= 2:
		timer.stop()
		shader_plane.get_active_material(0).set("shader_param/pixel_size", 1)
		is_aliasing = true 


func reset():
	player.reset()
	ghost_controller.reset()
	grid.reset_score_eatables()
	$UserInterface/ScoreLabel.set_score(-1)
	print("%s Game has been reset " % [Time.get_datetime_string_from_system()])
	
	
func health_decrease():
	
	pacman_health -= 1
	if pacman_health == 0:
		print("%s Lifes left: %s. Pacman is dead " % [Time.get_datetime_string_from_system(), pacman_health])
		$UserInterface.to_game_over()
		ghost_controller.stop_ghosts()
		player.to_game_over()
		$Player/pacman.visible = false
		$Light.set_param($Light.PARAM_ENERGY, 0.1)
		is_game_over = true
	else:
		stop_all_entities()
		$UserInterface/TextureRect/HealthLabel.health_cahnge(pacman_health)
		print("%s Pacman took damage. Lifes left: %s " % [Time.get_datetime_string_from_system(), pacman_health])
		start_reset()


func _unhandled_key_input(event):
	if event.is_pressed() and is_game_over:
		get_tree().change_scene_to_file("res://main_menu.tscn")
