extends Item
class_name TheDreadWarden
var attack_damage : int = 30
var attack_targets : int = 1
var attack_speed : int = 50
var legendary = true
var epic = "OnEquip"
var duration: float
var color = Color.PURPLE

func _initialize():
	attack_damage = randi_range(30, 40)
	attack_targets = 1
	attack_speed = randi_range(40, 60)
	tags.append("TheDreadWarden")
	values.append(5.0)
	colors.append(color)
	duration = 0.0

	tooltip = "Increases your attack damage based on your attack speed, but your windup time is set to" + str(values[0]) + "seconds."

func _get_values():
	return [attack_damage, attack_targets, attack_speed]	

func _get_tags():
	return ["attack_damage", "attack_targets", "attack_speed"]
