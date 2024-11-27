extends Item
class_name TheLastStand
var strength : int = 30
var dexterity : int = 0
var intelligence : int = 0
var mana_regen : int = 0
var legendary = true
var epic = "OnEquip"
var duration: float
var color = Color.GOLD

func _initialize():
	strength = randi_range(20, 30)
	dexterity = randi_range(20, 30)
	intelligence = randi_range(20, 30)
	mana_regen = randi_range(2, 5)
	tags.append("TheLastStand")
	values.append(80)
	colors.append(color)
	duration = 0.0

	tooltip = "Set your maximum and current cooldown reduction to 80%, but you are permanently rooted."

func _get_values():
	return [strength, dexterity, intelligence, mana_regen]	

func _get_tags():
	return ["strength", "dexterity", "intelligence", "mana_regen"]