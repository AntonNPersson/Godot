extends Task
class_name has_buffed_summons
var buffed = false

func _run(_delta):
	if !buffed and unit.summoned:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	buffed = true
	_success()

func _child_fail():
	_fail()
