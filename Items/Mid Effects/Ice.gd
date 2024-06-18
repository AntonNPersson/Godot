extends Item
class_name Ice
var increased_freeze_effectiveness: int
var increased_damage: int
var increased_mana_regen: int

func _initialize():
	tags.append("increased_freeze_effectiveness")
	tags.append("increased_damage")
	tags.append("increased_mana_regen")
	increased_freeze_effectiveness = randi() % 8 + 2
	increased_damage = randi() % 10 + 4
	increased_mana_regen = randi() % 50 + 9
	values.append(increased_freeze_effectiveness)
	values.append(increased_damage)
	values.append(increased_mana_regen)
	_remove_random_tag()
