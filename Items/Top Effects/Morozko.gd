extends Item
class_name Morozko
var epic
var unique
var duration: int
var color = Color.SKY_BLUE
var cooldown

func _initialize():
	duration = 0
	cooldown = 0
	epic = 'OnFrozen'
	unique = true
	tags.append("FrozenPercentageDamageBuff")
	values.append(randi() % 50 + 20)
	colors.append(color)

	tooltip = "On Frozen: Deal "+ str(values[0]) + "% increased damage to the target. (Unique)"
