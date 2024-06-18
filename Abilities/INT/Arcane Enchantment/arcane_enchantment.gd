extends Passive
@export var percentage_of_intelligence : float
func _update_passive():
	values[0] = unit.total_intelligence * (percentage_of_intelligence/100)
	unit.get_node('Control').on_action.emit(values[0], unit, unit, tags[0])

func _level_grants():
	percentage_of_intelligence = unit.total_intelligence * (increased_values[0]/100)
