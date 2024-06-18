extends Node2D
var barrier = 12

func _initialize():
	barrier = randi() % 20 + 12

func _get_values():
	return [barrier]

func _get_tags():
	return ["barrier"]