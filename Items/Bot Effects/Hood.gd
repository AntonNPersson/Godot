extends Item
class_name Hood
var mana_regen : float = 0.3
var barrier : int = 10

func _initialize():
	tags = ["mana_regen", "barrier"]
	mana_regen = round_to_dec(randf_range(0.2, 0.8), 2)
	barrier = randi() % 10 + 2
	values = [mana_regen, barrier]

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func _get_values():
	return values

func _get_tags():
	return tags