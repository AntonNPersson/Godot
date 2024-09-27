extends Item
class_name Robe
var barrier : int = 20

func _initialize():
	tags = ["barrier"]
	barrier = randi() % 15 + 5
	values = [barrier]
	icon = preload('res://Sprites/Icons/Robe.png')
	type = ["Defense"]

func _get_values():
	return [barrier]

func _get_tags():
	return ["barrier"]
 

