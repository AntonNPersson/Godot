extends Item
class_name Robe
var barrier : int = 20
var mana : int = 12

func _initialize():
	tags = ["barrier", "mana"]
	barrier = randi() % 15 + 5
	mana = randi() % 20 + 12
	values = [barrier, mana]
	icon = preload('res://Sprites/Icons/Robe.png')
	type = ["Defense"]

func _get_values():
	return [barrier, mana]

func _get_tags():
	return ["barrier", "mana"]
 

