extends Node2D
class_name Item
var values = []
var tags = []
var colors = []
var tooltip = ""
var icon = null

func _initialize():
	pass

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return values

func _get_tags():
	return tags

func _ascend(power):
	for i in range(values.size()):
		values[i] = round_to_dec(values[i] * power, 2)

func _increase_rarity(value : float):
	for i in range(values.size()):
		values[i] = int(values[i] * value)

func _remove_random_tag():
	var index = randi() % tags.size()
	values.remove_at(index)
	tags.remove_at(index)

func remove_part(original: String, to_remove: String) -> String:
	var start_index = original.find(to_remove)
	if start_index == -1:
		return original  # Substring not found
	var end_index = start_index + to_remove.length()
	return original.substr(0, start_index) + original.substr(end_index, original.length() - end_index)

func _get_tooltip():
	return tooltip
