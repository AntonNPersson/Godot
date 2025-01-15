extends Item
class_name Breastplate
var armor : int = 20
var health : int = 12

func _initialize():
	tags = ["armor", "health"]
	armor = randi() % 50 + 20
	health = randi() % 20 + 12
	values = [armor, health]
	icon = preload('res://Sprites/Icons/Breastplate.png')
	type = ["Defense"]
	# Types: Defense, Utility, Offense, All

func _get_values():
	return [armor, health]

func _get_tags():
	return ["armor", "health"]
 

