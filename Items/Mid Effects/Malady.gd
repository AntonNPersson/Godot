extends Item
class_name Malady
var increased_poison_damage: int
var increased_affliction_resistance: int

func _initialize():
	tags.append("increased_poison_damage")
	tags.append("increased_affliction_resistance")
	increased_poison_damage = randi() % 12 + 3
	increased_affliction_resistance = randi() % 4 + 2
	values.append(increased_poison_damage)
	values.append(increased_affliction_resistance)
