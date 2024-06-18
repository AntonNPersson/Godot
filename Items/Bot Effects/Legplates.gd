extends Node2D
var armor : int = 34

var tags = ["armor"]
var values = [armor]

func _initialize():
	armor = randi() % 70 + 5

func _get_values():
	return values

func _get_tags():
	return tags