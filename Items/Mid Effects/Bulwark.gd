extends Item
class_name Bulwark
var increased_armor: int
var increased_health: int
var increased_health_regen: int

func _initialize():
	tags.append("increased_health_regen")
	tags.append("increased_armor")
	tags.append("increased_health")
	increased_health_regen = randi() % 50 + 9
	increased_armor = randi() % 10 + 4
	increased_health = randi() % 9 + 4
	values.append(increased_health_regen)
	values.append(increased_armor)
	values.append(increased_health)

	_remove_random_tag()
