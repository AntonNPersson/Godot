extends Item
class_name Gloves
var attack_speed : float = 5
var evade : int = 7

func _initialize():
	tags = ["attack_speed", "evade"]
	attack_speed = randi() % 10 + 5
	evade = randi() % 50 + 10
	values = [attack_speed, evade]

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return values

func _get_tags():
	return tags
