extends Node2D
var armor : int = 20

var tags = ["armor"]
var values = [armor]

func _initialize():
	armor = randi() % 50 + 20

func _get_values():
	return values

func _get_tags():
	return tags
 

