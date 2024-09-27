extends Item
class_name Thoth
var epic
var duration: int
var color = Color.DARK_CYAN
var cooldown

func _initialize():
	duration = 0
	cooldown = 0
	epic = 'OnCast'
	tags.append("RefundMana")
	values.append(randi() % 25 + 5)
	colors.append(color)

	tooltip = "On Cast: Refund " + str(values[0]) + "% of spent mana."
