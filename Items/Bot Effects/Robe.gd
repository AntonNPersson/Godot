extends Node2D
var barrier : int = 20

var tags = ["barrier"]
var values = [barrier]

func _initialize():
	barrier = randi() % 15 + 5

func _get_values():
	return values

func _get_tags():
	return tags
 

