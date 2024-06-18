extends Node2D
var range : int = 25
var attack_damage : int = 12
var attack_speed : int = 10

func _initialize():
	range = 25
	attack_damage = randi_range(12, 22)
	attack_speed = 10


func _get_values():
	return [range, attack_damage, attack_speed]

func _get_tags():
	return ["range", "attack_damage", "attack_speed"]