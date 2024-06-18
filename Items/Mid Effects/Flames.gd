extends Item
class_name Flames
var increased_burn_damage: int
var increased_damage: int
var increased_mana: int

func _initialize():
	tags.append("increased_burn_damage")
	tags.append("increased_damage")
	tags.append("increased_mana")
	increased_burn_damage = randi() % 16 + 4
	increased_damage = randi() % 10 + 4
	increased_mana = randi() % 14 + 3
	values.append(increased_burn_damage)
	values.append(increased_damage)
	values.append(increased_mana)
	_remove_random_tag()
