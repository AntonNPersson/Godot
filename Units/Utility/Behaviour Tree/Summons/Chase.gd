extends Task
class_name Chase

func _run(_delta):
	if unit.is_rooted:
		_fail()
		return
	
	target = _get_closest_enemy()
	
	_move_random_target(target.global_position, _delta, true)
	if target == null:
		_fail()
		return
	_success()
		

