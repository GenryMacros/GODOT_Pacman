extends Node3D

var collision_area: Area3D = null

func _enter_tree():
	collision_area = $Score_Eatable_Area
	collision_area.area_entered.connect(_handle_collision)
	
	
func _handle_collision(area: Area3D):
	if area.name == "Player_Area" or area.name == "ghosts_house_area":
		queue_free()
	
