extends Task
class_name no_aggro

func _run(_delta):
	if !unit.has_aggro:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
