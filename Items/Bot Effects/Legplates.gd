extends Item
class_name Legplates
var armor : int = 34
var health : int = 12

func _initialize():
	tags = ["armor", "health"]
	armor = randi() % 70 + 5
	health = randi() % 20 + 12
	values = [armor, health]
	icon = preload('res://Sprites/Icons/Legplates.png')
	type = ["Defense"]

func _get_values():
	return [armor, health]

func _get_tags():
	return ["armor", "health"]