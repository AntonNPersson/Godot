extends Item
class_name Hermes
var epic
var unique
var duration: int
var color = Color.WEB_PURPLE
var cooldown

func _initialize():
	duration = 0
	cooldown = 0
	epic = 'OnCast'
	unique = true
	tags.append("DamagingTeleport")
	values.append(randi() % 10 + 1)
	colors.append(color)

	tooltip = "On Cast: Teleport to a viable random location, and deal " + str(values[0]) + " * (main stat) normal damage to surrounding enemies upon appearing."
