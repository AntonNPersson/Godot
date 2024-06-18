extends Node2D
class_name Item
var values = []
var tags = []

func _initialize():
	pass

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return values

func _get_tags():
	return tags

func _remove_random_tag():
	var index = randi() % tags.size()
	values.remove_at(index)
	tags.remove_at(index)

func _get_tooltip():
	var tooltip = ""
	for i in range(values.size()):
		if tags[i].contains("increased"):
			tooltip += values[i] + ": " + str(round_to_dec(tags[i], 2)) + "%\n"
		else:
			tooltip += values[i] + ": " + str(round_to_dec(tags[i], 2)) + "\n"
	return tooltip
