extends Item
class_name Sanguar
var epic
var unique
var duration: float
var color = Color.RED
var cooldown

func _initialize():
	duration = 0.2
	cooldown = 0
	epic = 'OnBleed'
	unique = true
	tags.append("LuckyBleed")
	values.append(randi() % 15 + 5)
	colors.append(color)

	tooltip = "On Bleed: Increase critical chance by "+ str(values[0]) + "% on the bleeding enemy. (Unique)"
