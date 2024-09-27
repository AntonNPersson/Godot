extends Item
class_name Exploration
var increased_experience = 10

func _initialize():
	increased_experience = increased_experience % 12 + 4

func _get_values():
	return [increased_experience]	

func _get_tags():
	return ["increased_experience"]