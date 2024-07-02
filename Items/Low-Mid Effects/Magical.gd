extends Item
class_name Magical
var intelligence = 10

func _initialize():
	intelligence = randi() % 12 + 8

func _get_values():
	return [intelligence]

func _get_tags():
	return ["intelligence"]