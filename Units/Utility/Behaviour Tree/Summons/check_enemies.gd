extends Task
class_name check_enemies

func _run(_delta):
	if _get_closest_enemy() == null:
		unit.has_aggro = false
		_fail()
		return
	unit._target = _get_closest_enemy()
	unit.has_aggro = true
	get_child(0)._run(_delta)
	_running()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
