extends Item
class_name Arcanic
var mana = 12

func _initialize():
	mana = randi() % 20 + 12

func _get_values():
	return [mana]

func _get_tags():
	return ["mana"]