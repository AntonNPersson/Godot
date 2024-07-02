extends Item
class_name Bow
var range : int = 200
var attack_damage : int = 15

func _initialize():
	range = 200
	attack_damage = randi_range(15, 25)


func _get_values():
	return [range, attack_damage]

func _get_tags():
	return ["range", "attack_damage"]
