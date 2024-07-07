extends Item
class_name Robe
var barrier : int = 20

func _initialize():
	tags = ["barrier"]
	barrier = randi() % 15 + 5
	values = [barrier]
	icon = preload('res://Sprites/Icons/Robe.png')

func _get_values():
	return values

func _get_tags():
	return tags
 

