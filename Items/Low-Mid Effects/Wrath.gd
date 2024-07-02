extends Item
class_name Wrath
var critical_chance : float = 0.3

func _initialize():
	critical_chance = round_to_dec(randf_range(0.3, 2.2), 2)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return [critical_chance]

func _get_tags():
	return ["critical_chance"]
