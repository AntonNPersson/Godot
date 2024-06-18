extends Node2D
var evade : int = 20

var tags = ["evade"]
var values = [evade]

func _initialize():
	evade = randi() % 50 + 20

func _get_values():
	return values

func _get_tags():
	return tags
 

