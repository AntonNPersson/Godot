extends Item
class_name Aeolus
var epic
var knockback_distance: int
var duration: int
var color = Color.LIGHT_CORAL

func _initialize():
	knockback_distance = 50
	duration = 0
	epic = 0
	tags.append("WindShout")
	values.append(knockback_distance)
	colors.append(color)

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

	tooltip = "On " + inputEvent + ": " + "An explosion of wind knocks back surrounding enemies for " + str(knockback_distance) + "pixels."
