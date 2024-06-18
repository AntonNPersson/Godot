extends Task
class_name has_unit_printed_dialogue
var dialogue = false

func _run(_delta):
	if !dialogue:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	dialogue = true
	_success()

func _child_fail():
	_fail()
