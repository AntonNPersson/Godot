extends Item
class_name Retaliation
var increased_thorns: int
var increased_damage: int
var increased_health: int

func _initialize():
	tags.append("increased_health")
	tags.append("increased_thorns")
	tags.append("increased_damage")
	increased_health = randi() % 9 + 4
	increased_thorns = randi() % 10 + 4
	increased_damage = randi() % 10 + 4
	values.append(increased_health)
	values.append(increased_thorns)
	values.append(increased_damage)

	_remove_random_tag()
