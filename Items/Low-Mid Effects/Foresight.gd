extends Node2D
var cooldown_reduction : int = 2

func _initialize():
	cooldown_reduction = randi() % 6 + 2

func _get_values():
	return [cooldown_reduction]

func _get_tags():
	return ["cooldown_reduction"]
