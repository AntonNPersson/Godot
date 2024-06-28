extends Item
class_name Artemis
var epic
var increased_movement_speed: int
var duration: int

func _initialize():
	increased_movement_speed = 50
	duration = 1
	epic = 0
	tags.append("PercentSpeedBuff")
	values.append(increased_movement_speed)

	var inputActions
	var inputEvent: String = ""

	if epic == 0:
		inputActions = InputMap.action_get_events("Ability_1")
	elif epic == 1:
		inputActions = InputMap.action_get_events("Ability_2")
	elif epic == 2:
		inputActions = InputMap.action_get_events("Ability_3")

	for input in inputActions:
		inputEvent = input.as_text()
		inputEvent = remove_part(inputEvent, "(Physical)")
		break

	tooltip = "On " + inputEvent + ": " + "Increases movement speed by " + str(increased_movement_speed) + "% for " + str(duration) + " second(s)."
