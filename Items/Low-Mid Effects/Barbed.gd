extends Item
class_name Barbed
var thorns = 12

func _initialize():
	thorns = randi() % 15 + 8

func _get_values():
	return [thorns]

func _get_tags():
	return ["thorns"]