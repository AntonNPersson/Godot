extends Item
class_name Staff
var strength : int = 0
var dexterity : int = 0
var intelligence : int = 0
var range : int = 175


func _initialize():
	var attribute = _adjust_attributes()
	match attribute:
		0:
			strength = randi_range(10, 15)
		1:
			dexterity = randi_range(10, 15)
		2:
			intelligence = randi_range(10, 15)
	range = 175

func _get_values():
	return [intelligence, range, strength, dexterity]

func _get_tags():
	return ["intelligence", "range", "strength", "dexterity"]

func _adjust_attributes():
	var ra = randi_range(0,2)
	return ra