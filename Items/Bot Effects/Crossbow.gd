extends Item
class_name Crossbow
var range : int = 125
var attack_damage : int = 7
var attack_speed : int = 30

func _initialize():
	range = 125
	attack_damage = randi_range(7, 12)
	attack_speed = 15

func _get_values():
	return [range, attack_damage, attack_speed]

func _get_tags():
	return ["range", "attack_damage", "attack_speed"]
