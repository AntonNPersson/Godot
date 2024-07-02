extends Item
class_name Everlasting
var strength = 10

func _initialize():
	strength = randi() % 12 + 8

func _get_values():
	return [strength]

func _get_tags():
	return ["strength"]