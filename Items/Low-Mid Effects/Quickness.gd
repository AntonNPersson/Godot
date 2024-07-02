extends Item
class_name Quickness
var quick_attack_chance : float = 0.8

func _initialize():
	quick_attack_chance = round_to_dec(randf_range(0.8, 1.5), 2)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return [quick_attack_chance]

func _get_tags():
	return ["quick_attack_chance"]
