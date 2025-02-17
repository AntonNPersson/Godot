extends Item
class_name Heka
var epic
var unique
var duration: int
var color = Color.WEB_PURPLE
var cooldown

func _initialize():
	duration = 0
	cooldown = randi() % 10 + 4
	epic = 'OnHit'
	unique = true
	tags.append("ChaosMagic")
	values.append(10)
	colors.append(color)

	tooltip = "On Hit: Cast a random spell on the closest enemy (level scaling with lowest owned ability), has " + str(cooldown) +" seconds cooldown."
