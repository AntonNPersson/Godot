extends Item
class_name Legs
var evade : int = 34
var stamina : int = 12

func _initialize():
	tags = ["evade", "stamina"]
	evade = randi() % 70 + 5
	stamina = randi() % 20 + 12
	values = [evade, stamina]
	icon = preload('res://Sprites/Icons/Legs.png')
	type = ["Defense"]

func _get_values():
	return [evade, stamina]

func _get_tags():
	return ["evade", "stamina"]
