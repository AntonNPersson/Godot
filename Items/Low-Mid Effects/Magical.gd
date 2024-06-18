extends Node2D
var intelligence = 10

func _initialize():
	intelligence = randi() % 12 + 8

func _get_values():
	return [intelligence]

func _get_tags():
	return ["intelligence"]