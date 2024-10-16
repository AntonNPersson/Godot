extends Item
class_name Artemis
var epic
var increased_movement_speed: int
var duration: int
var color = Color.GREEN_YELLOW

func _initialize():
	increased_movement_speed = randi() % 15 + 10
	duration = randi() % 3 + 1
	epic = 'OnCast'
	tags.append("PercentSpeedBuff")
	values.append(increased_movement_speed)
	colors.append(color)

	tooltip = "On Cast: Increases movement speed by " + str(increased_movement_speed) + "% for " + str(duration) + " second(s)."
