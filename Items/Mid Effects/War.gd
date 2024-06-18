extends Item
class_name War
var increased_armor: int
var increased_damage: int
var increased_bleed_damage: int

func _initialize():
	tags.append("increased_armor")
	tags.append("increased_damage")
	tags.append("increased_bleed_damage")
	increased_armor = randi() % 14 + 4
	increased_damage = randi() % 10 + 4
	increased_bleed_damage = randi() % 16 + 4
	values.append(increased_armor)
	values.append(increased_damage)
	values.append(increased_bleed_damage)
	_remove_random_tag()
