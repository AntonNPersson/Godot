extends Item
class_name Mind
var increased_barrier: int
var increased_barrier_regen: int
var increased_intelligence: int

func _initialize():
	tags.append("increased_intelligence")
	tags.append("increased_barrier")
	tags.append("increased_barrier_regen")
	increased_intelligence = randi() % 12 + 3
	increased_barrier = randi() % 10 + 4
	increased_barrier_regen = randi() % 50 + 9
	values.append(increased_intelligence)
	values.append(increased_barrier)
	values.append(increased_barrier_regen)

	_remove_random_tag()
