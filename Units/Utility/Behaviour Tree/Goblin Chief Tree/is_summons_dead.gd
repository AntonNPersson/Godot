extends Task
class_name is_summons_dead

func _run(_delta):
	if !unit.summoned:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	_fail()

func _child_fail():
	_fail()
