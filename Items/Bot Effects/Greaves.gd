extends Item
class_name Greaves
var speed : int = 1
var armor : int = 3

func _initialize():
	speed = randi() % 3 + 1
	armor = randi() % 50 + 20

func _get_values():
	return [speed, armor]

func _get_tags():
	return [ "speed", "armor"]