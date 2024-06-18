extends Node2D
var attack_speed : float = 5
var evade : int = 7

var tags = ["attack_speed", "evade"]
var values = [attack_speed, evade]
func _initialize():
	attack_speed = randi() % 10 + 5
	evade = randi() % 50 + 10

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return values

func _get_tags():
	return tags
