extends Item
class_name Chronos
var epic
var duration: float
var color = Color.GOLD
var cooldown

func _initialize():
	duration = 0.0
	cooldown = 0
	epic = 'OnEquip'
	tags.append("ChronosBlessing")
	values.append(randi() % 10 + 5)
	colors.append(color)

	tooltip = "On Equip: Increase cooldown reduction by "+ str(values[0]) + "%."
