extends Item
class_name Breastplate
var armor : int = 20

func _initialize():
	tags = ["armor"]
	armor = randi() % 50 + 20
	values = [armor]
	icon = preload('res://Sprites/Icons/Breastplate.png')

func _get_values():
	return values

func _get_tags():
	return tags
 

