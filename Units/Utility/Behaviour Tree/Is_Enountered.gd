extends Task

class_name is_encountered

func _run(_delta):
	if unit.has_aggro:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	_running()

func _child_fail():
	_running()