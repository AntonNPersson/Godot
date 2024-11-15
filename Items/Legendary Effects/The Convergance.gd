extends Item
class_name TheConvergance
var attack_damage : int = 60
var increased_attack_damage : int = 0
var attack_speed : int = 0
var bonus_stamina_regen : int = 0
var legendary = true
var epic = "OnEquip"
var duration: float
var color = Color.GOLD

func _initialize():
	attack_damage = randi_range(30, 60)
	increased_attack_damage = randi_range(7, 13)
	attack_speed = randi_range(-14, -28)
	bonus_stamina_regen = randi_range(2, 5)
	tags.append("TheConvergance")
	values.append(true)
	colors.append(color)
	duration = 0.0

	tooltip = "Reduces your range to melee range but increases your basic attack damage by a percentage based on the range lost."

func _get_values():
	return [attack_damage, increased_attack_damage, attack_speed, bonus_stamina_regen]	

func _get_tags():
	return ["attack_damage", "increased_attack_damage", "attack_speed", "bonus_stamina_regen"]