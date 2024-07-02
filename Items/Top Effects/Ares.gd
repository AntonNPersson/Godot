extends Item
class_name Ares
var epic
var increased_attack_damage: int
var duration: int
var color = Color.RED

func _initialize():
	increased_attack_damage = 10
	duration = 5
	epic = randi() % 3
	tags.append("PercentAttackDamageBuff")
	values.append(increased_attack_damage)
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

	tooltip = "On " + inputEvent + ": " + "Increases attack damage by " + str(increased_attack_damage) + "% for " + str(duration) + " second(s)."
