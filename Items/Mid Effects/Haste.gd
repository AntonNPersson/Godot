extends Item
class_name Haste
var increased_movement_speed: int
var increased_dexterity: int
var increased_evade: int

func _initialize():
	tags.append("increased_movement_speed")
	tags.append("increased_dexterity")
	tags.append("increased_evade")
	increased_movement_speed = randi() % 8 + 2
	increased_dexterity = randi() % 12 + 3
	increased_evade = randi() % 14 + 4
	values.append(increased_movement_speed)
	values.append(increased_dexterity)
	values.append(increased_evade)
	_remove_random_tag()
