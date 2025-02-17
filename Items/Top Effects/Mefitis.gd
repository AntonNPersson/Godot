extends Item
class_name Mefitis
var epic
var unique
var duration: float
var color = Color.WEB_PURPLE
var cooldown

func _initialize():
	duration = 0.2
	cooldown = 0
	epic = 'OnPoison'
	unique = true
	tags.append("LuckyPoison")
	values.append(randi() % 15 + 5)
	colors.append(color)

	tooltip = "On Poison: Increase critical chance by "+ str(values[0]) + "% on the poisoned enemy."
