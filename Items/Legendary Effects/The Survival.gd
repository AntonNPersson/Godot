extends Item
class_name TheSurvival
var armor : int = 30
var health : int = 0
var increased_damage : int = 0
var legendary = true
var epic = "OnEquip"
var duration: float
var color = Color.RED

func _initialize():
	armor = randi_range(1300, 2400)
	health = randi_range(200, 400)
	increased_damage = randi_range(7, 13)
	tags.append("TheSurvival")
	values.append(100)
	colors.append(color)
	duration = 0.0

	tooltip = "Increase your lifesteal by 100%, but constantly take 3% of you max health damage every second in combat."

func _get_values():
	return [armor, health, increased_damage]	

func _get_tags():
	return ["armor", "health", "increased_damage"]