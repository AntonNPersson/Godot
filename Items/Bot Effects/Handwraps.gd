extends Item
class_name Handwraps
var attack_speed : float = 5
var barrier : int = 7

func _initialize():
	tags = ["attack_speed", "barrier"]
	attack_speed = randi() % 10 + 5
	barrier = randi() % 10 + 2
	values = [attack_speed, barrier]
	icon = preload('res://Sprites/Icons/Handwraps.png')
	type = ["Defense", "Offense"]

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return [attack_speed, barrier]

func _get_tags():
	return ["attack_speed", "barrier"]
