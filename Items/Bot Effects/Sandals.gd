extends Node2D
var speed : int = 1
var barrier : int = 3

func _initialize():
	speed = randi() % 3 + 1
	barrier = randi() % 10 + 3

func _get_values():
	return [speed, barrier]

func _get_tags():
	return [ "speed", "barrier"]