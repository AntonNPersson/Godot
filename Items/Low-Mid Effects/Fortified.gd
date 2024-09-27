extends Item
class_name Fortified
var block = 0

func _initialize():
	block = randi() % 1 + 2

func _get_values():
	return [block]

func _get_tags():
	return ["block"]
