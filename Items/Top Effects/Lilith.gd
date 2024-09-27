extends Item
class_name Lilith
var epic
var duration: float
var color = Color.DARK_RED
var cooldown

func _initialize():
	duration = 0
	cooldown = 0
	epic = 'OnHit'
	tags.append("VampiricalHeal")
	values.append(randi() % 15 + 5)
	colors.append(color)

	tooltip = "On Hit: Heal "+ str(values[0]) + "% of damaged dealt."
