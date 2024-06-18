extends Node2D
var evade : int = 34

var tags = ["evade"]
var values = [evade]

func _initialize():
	evade = randi() % 70 + 5

func _get_values():
	return values

func _get_tags():
	return tags