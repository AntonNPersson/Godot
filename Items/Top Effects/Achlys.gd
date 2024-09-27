extends Item
class_name Achlys
var epic
var unique
var duration: int
var color = Color.GREEN_YELLOW
var cooldown

func _initialize():
	duration = 5
	cooldown = 0
	epic = 'OnHit'
	unique = true
	tags.append("PoisonAttack")
	values.append(randi() % 10 + 1)
	colors.append(color)

	tooltip = "On Hit: Has "+ str(values[0]) + "% chance to poison the target for "+ str(values[0]) + " * (main stat) poison damage over 5 seconds. (Unique)"
