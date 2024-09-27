extends Item
class_name Helmet
var mana_regen : float = 0.3
var armor : int = 10

func _initialize():
	tags = ["mana_regen", "armor"]
	mana_regen = round_to_dec(randf_range(0.2, 0.8), 2)
	armor = randi() % 42 + 10
	values = [mana_regen, armor]
	icon = preload('res://Sprites/Icons/Helmet.png')
	type = ["All"]

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func _get_values():
	return [mana_regen, armor]

func _get_tags():
	return ["mana_regen", "armor"]