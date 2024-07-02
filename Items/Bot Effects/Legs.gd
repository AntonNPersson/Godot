extends Item
class_name Legs
var evade : int = 34

func _initialize():
	tags = ["evade"]
	evade = randi() % 70 + 5
	values = [evade]

func _get_values():
	return values

func _get_tags():
	return tags