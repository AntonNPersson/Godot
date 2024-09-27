extends Item
class_name Chest
var evade : int = 20

func _initialize():
	tags = ["evade"]
	evade = randi() % 50 + 20
	values = [evade]
	icon = preload('res://Sprites/Icons/Chest.png')
	type = ["Defense"]
	# Types: Defense, Utility, Offense, All

func _get_values():
	return [evade]

func _get_tags():
	return ["evade"]
 

