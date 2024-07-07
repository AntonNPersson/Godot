extends Item
class_name Gauntlets
var attack_speed : float = 5
var armor : int = 7

func _initialize():
	tags = ["attack_speed", "armor"]
	attack_speed = randi() % 10 + 5
	armor = randi() % 50 + 10
	values = [attack_speed, armor]
	icon = preload('res://Sprites/Icons/Gauntlet.png')

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return values

func _get_tags():
	return tags
