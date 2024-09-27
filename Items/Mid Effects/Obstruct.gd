extends Item
class_name Obstruct
var increased_block: int
var increased_crowd_control_resistance: int

func _initialize():
	tags.append("increased_block")
	tags.append("increased_crowd_control_resistance")
	increased_block = randi() % 16 + 4
	increased_crowd_control_resistance = randi() % 4 + 2
	values.append(increased_block)
	values.append(increased_crowd_control_resistance)
