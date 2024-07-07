extends Item
class_name Scepter
var strength : int = 0
var dexterity : int = 0
var intelligence : int = 0
var range : int = 15
var increased_global_weight : int = -30

func _initialize():
	var attribute = _adjust_attributes()
	match attribute:
		0:
			strength = randi_range(10, 20)
		1:
			dexterity = randi_range(10, 20)
		2:
			intelligence = randi_range(10, 20)
	range = 15
	increased_global_weight = -30
	icon = preload('res://Sprites/Icons/Scepter.png')

func _get_values():
	return [intelligence, range, strength, dexterity, increased_global_weight]

func _get_tags():
	return ["intelligence", "range", "strength", "dexterity", "increased_global_weight"]

func _adjust_attributes():
	var ra = randi_range(0,2)
	return ra