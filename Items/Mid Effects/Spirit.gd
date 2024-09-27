extends Item
class_name Spirit
var increased_vitality: int
var increased_slow_resistance: int

func _initialize():
	tags.append("increased_vitality")
	tags.append("increased_slow_resistance")
	increased_vitality = randi() % 12 + 3
	increased_slow_resistance = randi() % 4 + 2
	values.append(increased_vitality)
	values.append(increased_slow_resistance)
