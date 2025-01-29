extends Item
class_name Rejuvenation
var health_regen : float = 0.2

func _initialize():
	health_regen = round_to_dec(randf_range(0.05, 0.3), 2)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return [health_regen]

func _get_tags():
	return ["health_regen"]
