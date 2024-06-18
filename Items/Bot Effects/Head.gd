extends Node2D
var mana_regen : float = 0.3
var evade : int = 10

var tags = ["mana_regen", "evade"]
var values = [mana_regen, evade]

func _initialize():
	mana_regen = round_to_dec(randf_range(0.2, 0.8), 2)
	evade = randi() % 42 + 10

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func _get_values():
	return values

func _get_tags():
	return tags