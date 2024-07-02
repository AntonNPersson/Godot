extends Item
class_name Ares
var epic
var increased_attack_damage: int
var duration: int
var color = Color.RED

func _initialize():
	increased_attack_damage = 10
	duration = 5
	epic = 'OnCast'
	tags.append("PercentAttackDamageBuff")
	values.append(increased_attack_damage)
	colors.append(color)

	tooltip = "On Cast: Increases attack damage by " + str(increased_attack_damage) + "% for " + str(duration) + " second(s)."
