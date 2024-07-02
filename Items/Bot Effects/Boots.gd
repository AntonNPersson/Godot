extends Item
class_name Boots
var speed : int = 1
var evade : int = 20

func _initialize():
	speed = randi() % 3 + 1
	evade = randi() % 50 + 20

func _get_values():
	return [speed, evade]

func _get_tags():
	return [ "speed", "evade"]