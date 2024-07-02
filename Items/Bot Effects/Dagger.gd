extends Item
class_name Dagger
var range : int = 15
var attack_damage : int = 8
var quick_attack_chance : int = 100

func _initialize():
	range = 15
	attack_damage = randi_range(4, 6)
	quick_attack_chance = 100



func _get_values():
	return [range, attack_damage, quick_attack_chance]

func _get_tags():
	return ["range", "attack_damage", "quick_attack_chance"]