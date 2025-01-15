extends Item
class_name Chest
var evade : int = 20
var stamina : int = 12

func _initialize():
	tags = ["evade", "stamina"]
	evade = randi() % 50 + 20
	stamina = randi() % 20 + 12
	values = [evade, stamina]
	icon = preload('res://Sprites/Icons/Chest.png')
	type = ["Defense"]
	# Types: Defense, Utility, Offense, All

func _get_values():
	return [evade, stamina]

func _get_tags():
	return ["evade", "stamina"]
 

