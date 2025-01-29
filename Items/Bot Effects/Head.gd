extends Item
class_name Head
var mana_regen : float = 0.3
var evade : int = 10

func _initialize():
	tags = ["mana_regen", "evade"]
	mana_regen = round_to_dec(randf_range(0.05, 0.4), 2)
	evade = randi() % 42 + 10
	values = [mana_regen, evade]
	icon = preload('res://Sprites/Icons/Head.png')
	type = ["All"]

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func _get_values():
	return [mana_regen, evade]

func _get_tags():
	return ["mana_regen", "evade"]
