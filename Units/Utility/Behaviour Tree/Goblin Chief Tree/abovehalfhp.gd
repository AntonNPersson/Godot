extends Task

class_name above_half

func _run(_delta):
	if unit.current_health > unit.total_health/2:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	_running()

func _child_fail():
	_running()
