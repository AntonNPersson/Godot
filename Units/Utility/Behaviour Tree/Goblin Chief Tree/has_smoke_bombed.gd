extends Task
class_name has_smoke_bombed
var bombed = false

func _run(_delta):
	if !bombed:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	bombed = true
	_success()

func _child_fail():
	_fail()
