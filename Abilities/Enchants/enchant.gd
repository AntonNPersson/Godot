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

# 0 = Line, 1 = EnemyTarget, 2 = AllyTarget, 3 = Area, 4 = Passive, 5 = Self, 6 = Movement, 7 = EnemyAura, 8 = AllyAura, 9 = Summon

func _initialize():
	values = values
	extra["tooltip"] = tooltip

func _get_tooltip():
	var updated_tooltip = ""
	for i in range(0, values.size()):
		updated_tooltip = tooltip.replace("Value" + str(i), str(values[i]))
		if unique and "Unique" not in tooltip:
			updated_tooltip += "\n\nUnique"
	return updated_tooltip