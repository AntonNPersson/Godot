extends Item
class_name Staff
var strength : int = 0
var dexterity : int = 0
var intelligence : int = 0
var range : int = 175
var attack_damage : int = 3


func _initialize():
	attack_damage = randi_range(1, 2)
	var attribute = _adjust_attributes()
	match attribute:
		0:
			strength = randi_range(10, 15)
		1:
			dexterity = randi_range(10, 15)
		2:
			intelligence = randi_range(10, 15)
	range = 175
	icon = preload('res://Sprites/Icons/Staff.png')

func _get_values():
	return [intelligence, range, strength, dexterity, attack_damage]

func _get_tags():
	return ["intelligence", "range", "strength", "dexterity", "attack_damage"]

func _adjust_attributes():
	var ra = randi_range(0,2)
	return ra