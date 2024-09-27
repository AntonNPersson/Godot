extends Item
class_name Ignis
var epic
var unique
var duration: int
var color = Color.WEB_PURPLE
var cooldown

func _initialize():
	duration = 0
	cooldown = 4
	epic = 'OnBurn'
	unique = true
	tags.append("BurnHeal")
	values.append(randi() % 30 + 20)
	colors.append(color)

	tooltip = "On Burn: Heal "+ str(values[0]) + "% of damaged dealt. (Unique)"
