extends Passive

func _update_passive():
	unit.get_node('Control').on_action.emit(values[0], unit, unit, tags[0])
