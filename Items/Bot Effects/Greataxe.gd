extends Item
class_name Greataxe
var range : int = 15
var attack_damage : int = 10
var attack_speed : int = -30
var attack_targets : int = 2

func _initialize():
	range = 15
	attack_damage = randi_range(4, 6)
	attack_speed = -15
	attack_targets = 2
	icon = preload('res://Sprites/Icons/Greataxe.png')


func _get_values():
	return [range, attack_damage, attack_speed, attack_targets]

func _get_tags():
	return ["range", "attack_damage", "attack_speed", "attack_targets"]