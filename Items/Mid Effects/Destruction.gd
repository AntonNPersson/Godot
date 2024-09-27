extends Item
class_name Destruction
var increased_attack_damage = 10.0

func _initialize():
	increased_attack_damage = randi() % 8 + 3

func _get_values():
	return [increased_attack_damage]	

func _get_tags():
	return ["increased_attack_damage"]
