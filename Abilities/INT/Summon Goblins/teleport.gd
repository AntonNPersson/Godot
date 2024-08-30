extends Task
class_name teleport

func _run(_delta):
	if unit.is_rooted:
		_fail()
		return
	
	target = _get_closest_target()
	if target == null:
		_fail()
		return

	unit.global_position = target.global_position
	_success()
		

