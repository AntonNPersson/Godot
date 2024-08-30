extends Item
class_name Ares
var epic
var unique
@export var increased_attack_damage: int
@export var duration: int
@export var color = Color.RED

func _initialize():
	increased_attack_damage = 10
	duration = 5
	epic = 'OnCast'
	unique = false
	tags.append("PercentAttackDamageBuff")
	values.append(increased_attack_damage)
	colors.append(color)

	tooltip = "On Cast: Increases attack damage by " + str(increased_attack_damage) + "% for " + str(duration) + " second(s)."
