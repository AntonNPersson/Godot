extends Item
class_name TheDestroyer
var attack_damage : int = 15
var increased_attack_damage : int = 0
var attack_speed : int = 0
var armor : int = 0
var unique = true
var unique_type = "Weapon"

func _initialize():
	attack_damage = randi_range(4, 8)
	increased_attack_damage = randi_range(2, 5)
	attack_speed = randi_range(4, 8)
	armor = randi_range(2, 5)

func _get_values():
	return [attack_damage, increased_attack_damage, attack_speed, armor]	

func _get_tags():
	return ["attack_damage", "increased_attack_damage", "attack_speed", "armor"]