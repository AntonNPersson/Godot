extends Node2D
var double_cast_chance : float = 0.8

func _initialize():
	double_cast_chance = round_to_dec(randf_range(0.8, 1.5), 2)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return [double_cast_chance]

func _get_tags():
	return ["double_cast_chance"]
