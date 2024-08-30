extends Item
class_name Artemis
var epic
var unique
var increased_movement_speed: int
var duration: int
var color = Color.GREEN_YELLOW

func _initialize():
	increased_movement_speed = 50
	duration = 1
	epic = 'OnCast'
	unique = false
	tags.append("PercentSpeedBuff")
	values.append(increased_movement_speed)
	colors.append(color)

	tooltip = "On Cast: Increases movement speed by " + str(increased_movement_speed) + "% for " + str(duration) + " second(s)."
