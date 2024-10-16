extends Passive
@export var percentage_of_speed : float
func _update_passive():
	values[0] = unit.total_speed * (percentage_of_speed/100)
	unit.get_node('Control').on_action.emit(values[0], unit, unit, tags[0], self)

func _level_grants():
	percentage_of_speed = unit.total_speed * (increased_values[0]/100)
	_update_passive()
