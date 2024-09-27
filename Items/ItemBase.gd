extends Node2D
class_name Item
var values = []
var tags = []	
var colors = []
var tooltip = ""
var icon = null
var type = ["All"]
var is_using = false

var weapon_tooltip = ""

func _initialize():
	pass

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _get_values():
	return values

func _get_tags():
	return tags

func _use_weapon(player, delta):
	pass

func _initialize_weapon(player):
	pass

func _pre_initialize_weapon(player):
	pass

func _change_weapon_cooldown(value):
	pass

func _ascend(power):
	for i in range(_get_tags().size()):
		set(_get_tags()[i],  _get_values()[i] * power)

func _increase_rarity(value : float, flat_value : float):
	for i in range(_get_tags().size()):
		if _get_tags()[i] == "attack_damage" or _get_tags()[i] == "barrier" or _get_tags()[i] == "armor" or _get_tags()[i] == "evade" or _get_tags()[i] == "intelligence" or _get_tags()[i] == "dexterity" or _get_tags()[i] == "strength":
			if _get_values()[i] > 0.0:
				set(_get_tags()[i],  int(_get_values()[i] * value) + flat_value)

func _get_closest_visible_enemy_to_mouse():
	# Finds the closest visible enemy to the mouse position.
	var closest_node = null
	var closest_distance = 99999999
	
	if get_tree().get_nodes_in_group('enemies'):
		for child in get_tree().get_nodes_in_group('enemies'):
			var distance = get_global_mouse_position().distance_to(child.global_position)
		
			if distance < closest_distance:
				closest_distance = distance
				closest_node = child

	return closest_node

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

func _get_item_data():
	var data = {
		"name" : name,
		"values" : _get_values(),
		"tags" : _get_tags()
	}
	return data
