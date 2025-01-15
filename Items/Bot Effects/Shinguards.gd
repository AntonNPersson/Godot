extends Item
class_name Shinguards
var barrier : int = 10
var mana : int = 12

func _initialize():
	tags = ["barrier", "mana"]
	barrier = randi() % 15 + 5
	mana = randi() % 20 + 12
	values = [barrier, mana]
	icon = preload('res://Sprites/Icons/Shinguards.png')
	type = ["Defense", "Utility"]

func _get_values():
	return [barrier, mana]

func _get_tags():
	return ["barrier", "mana"]