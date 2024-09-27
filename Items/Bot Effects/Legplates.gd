extends Item
class_name Legplates
var armor : int = 34

func _initialize():
	tags = ["armor"]
	armor = randi() % 70 + 5
	values = [armor]
	icon = preload('res://Sprites/Icons/Legplates.png')
	type = ["Defense"]

func _get_values():
	return [armor]

func _get_tags():
	return ["armor"]