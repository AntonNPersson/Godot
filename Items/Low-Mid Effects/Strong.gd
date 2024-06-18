extends Node2D
var health = 12

func _initialize():
	health = randi() % 20 + 12

func _get_values():
	return [health]

func _get_tags():
	return ["health"]