extends Task
class_name Chase

func _run(_delta):
	if unit.is_rooted or unit.is_stunned or !is_instance_valid(unit._target) or unit._target == null:
		_success()
		return
	
	_move_random_target(unit._target.global_position, _delta)
	_running()
	if unit.global_position.distance_to(unit._target.global_position) <= unit.total_range - 10:
		_fail()
		return
	


		

