extends Item
class_name Vitalizing
var vitality = 12

func _initialize():
	vitality = randi() % 12 + 5

func _get_values():
	return [vitality]

func _get_tags():
	return ["vitality"]
