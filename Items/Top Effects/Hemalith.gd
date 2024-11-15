extends Item
class_name hemalith
var epic
var unique
var duration: int
var color = Color.RED
var cooldown

func _initialize():
	duration = 3
	cooldown = 0
	epic = 'OnHit'
	unique = true
	tags.append("BleedAttack")
	values.append(randi() % 16 + 3)
	colors.append(color)

	tooltip = "On Hit: Has "+ str(values[0]) + "% chance to bleed the target for "+ str(values[0]/3) + " * (main stat) bleed damage over 3 seconds. (Unique)"
