extends Control


@onready var play_button: Button = $Play
@onready var exit_button: Button = $Exit


func _ready():
	play_button.button_down.connect(start_game)
	exit_button.button_down.connect(exit)


func start_game():
	get_tree().change_scene_to_file("res://game_level_0.tscn")
	
	
func exit():
	get_tree().quit()
