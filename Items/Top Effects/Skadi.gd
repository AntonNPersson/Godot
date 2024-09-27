extends Item
class_name Skadi
var epic
var unique
var duration: int
var color = Color.GREEN_YELLOW
var cooldown

func _initialize():
	duration = 0
	cooldown = 0
	epic = 'OnFrozen'
	unique = true
	tags.append("FrozenQuickAttack")
	values.append(100)
	colors.append(color)

	tooltip = "On Frozen: Has "+ str(values[0]) + "% chance to instantly Quick Attack the target"
