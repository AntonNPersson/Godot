extends Node2D
var dexterity = 10

func _initialize():
	dexterity = randi() % 12 + 6

func _get_values():
	return [dexterity]	

func _get_tags():
	return ["dexterity"]