extends Item
class_name Legs
var evade : int = 34

func _initialize():
	tags = ["evade"]
	evade = randi() % 70 + 5
	values = [evade]
	icon = preload('res://Sprites/Icons/Legs.png')
	type = ["Defense"]

func _get_values():
	return [evade]

func _get_tags():
	return ["evade"]
