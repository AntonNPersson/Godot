extends Item
class_name Shinguards
var barrier : int = 10

func _initialize():
	tags = ["barrier"]
	barrier = randi() % 15 + 5
	values = [barrier]
	icon = preload('res://Sprites/Icons/Shinguards.png')

func _get_values():
	return values

func _get_tags():
	return tags