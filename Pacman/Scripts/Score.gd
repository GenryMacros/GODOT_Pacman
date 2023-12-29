extends Label

var score: float = -1

func _ready():
	pass

func _on_eatable_consume(score_increment: float):
	score += score_increment
	if score == 0:
		return
	text = "HIGH SCORE 
		%s" % score
		

func set_score(new_score: float):
	score = new_score
	text = "HIGH SCORE 
			00"
