extends Node2D
class_name enchant
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

@export var tags : Array[String]
@export var values : Array[float]
@export var types : Array[int]
@export var extra : Dictionary

@export var unique = false
enum Rarities {Common, Rare, Epic, Legendary}
@export var rarity : Rarities
# 0 = Line, 1 = EnemyTarget, 2 = AllyTarget, 3 = Area, 4 = Passive, 5 = Self, 6 = Movement, 7 = EnemyAura, 8 = AllyAura, 9 = Summon

func _initialize():
	values = values
	extra["tooltip"] = tooltip

func _get_rarity():
	if rarity == Rarities.Common:
		return 50
	elif rarity == Rarities.Rare:
		return 65
	elif rarity == Rarities.Epic:
		return 88
	elif rarity == Rarities.Legendary:
		return 100

func _get_tooltip():
	var updated_tooltip = ""
	for i in range(0, values.size()):
		updated_tooltip = tooltip.replace("Value" + str(i), str(values[i]))
		if unique and "Unique" not in tooltip:
			updated_tooltip += " [color=yellow](Unique)[/color]\n"
	return updated_tooltip

func _get_tooltip_2():
	var updated_tooltip = ""
	for i in range(0, values.size()):
		updated_tooltip = tooltip
		if unique and "Unique" not in tooltip:
			updated_tooltip += " [color=yellow](Unique)[/color]\n"
	return updated_tooltip