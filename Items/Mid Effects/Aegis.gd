extends Item
class_name Aegis
var increased_heal_effectiveness: int
var increased_vitality: int

func _initialize():
	tags.append("increased_heal_effectiveness")
	tags.append("increased_vitality")
	increased_heal_effectiveness = randi() % 6 + 3
	increased_vitality = randi() % 10 + 4
	values.append(increased_heal_effectiveness)
	values.append(increased_vitality)

