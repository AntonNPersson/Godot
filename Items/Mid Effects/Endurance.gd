extends Item
class_name Endurance
var increased_strength: int
var increased_stamina: int
var increased_stamina_regen: int

func _initialize():
	tags.append("increased_strength")
	tags.append("increased_stamina")
	tags.append("increased_stamina_regen")
	increased_strength = randi() % 12 + 3
	increased_stamina = randi() % 8 + 2
	increased_stamina_regen = randi() % 10 + 4
	values.append(increased_strength)
	values.append(increased_stamina)
	values.append(increased_stamina_regen)
	_remove_random_tag()
