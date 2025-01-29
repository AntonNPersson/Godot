extends Item
class_name Elusiveness
var increased_evade: int
var increased_stamina_regen: int
var increased_stamina: int

func _initialize():
	tags.append("increased_stamina")
	tags.append("increased_evade")
	tags.append("increased_stamina_regen")
	increased_stamina = randi() % 12 + 3
	increased_evade = randi() % 10 + 4
	increased_stamina_regen = randi() % 50 + 9
	values.append(increased_stamina)
	values.append(increased_evade)
	values.append(increased_stamina_regen)

	_remove_random_tag()
