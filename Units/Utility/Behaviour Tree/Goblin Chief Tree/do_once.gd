extends Task
class_name do_once
var done = false

func _run(_delta):
	if !done:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	done = true
	_success()

func _child_fail():
	_fail()
