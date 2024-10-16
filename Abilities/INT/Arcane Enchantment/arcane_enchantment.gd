extends Passive
var percentage_of_intelligence : float
func _update_passive():
	percentage_of_intelligence = values[0]
	values[0] = unit.total_intelligence * (percentage_of_intelligence/100)
	unit.get_node('Control').on_action.emit(values[0], unit, unit, tags[0], self)

func _level_grants():
	percentage_of_intelligence += increased_values[0]
	_update_passive()
