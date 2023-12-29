extends Control

@onready var game_score_label: Label = $ScoreLabel
@onready var lives_rect: TextureRect = $TextureRect
@onready var game_over_screen: Control = $GameOver
@onready var gg_screen: Control = $GG


func to_game():
	game_score_label.visible = true
	lives_rect.visible = true
	game_over_screen.visible = false
	gg_screen.visible = false
	
	
func to_game_over():
	game_score_label.visible = false
	lives_rect.visible = false
	game_over_screen.visible = true
	$GameOver/score.text = str(game_score_label.score)
	

func to_gg():
	game_score_label.visible = false
	lives_rect.visible = false
	game_over_screen.visible = false
	gg_screen.visible = true
	
