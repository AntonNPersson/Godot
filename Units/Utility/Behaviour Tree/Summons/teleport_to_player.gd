extends Task
class_name teleport_to_player

func _run(_delta):
	unit.global_position = _get_closest_target().global_position
	_success()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
