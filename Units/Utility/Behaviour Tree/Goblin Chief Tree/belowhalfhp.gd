extends Task
class_name below_half

func _run(_delta):
	if unit.current_health <= unit.total_health/2:
		get_child(0)._run(_delta)
		_running()
	else:
		_success()
		
func _child_success():
	_success()

func _child_fail():
	_success()
