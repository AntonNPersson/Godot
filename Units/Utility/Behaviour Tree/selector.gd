class_name selector extends Task
var current_child = 0

func _run(_delta):
	get_child(current_child)._run(_delta)
	_running()

func _child_success():
	current_child = 0
	_success()
	
func _child_fail():
	current_child += 1
	if current_child >= get_child_count():
		current_child = 0
		_fail()	
