extends Task
class_name Chase

func _run(_delta):
	if unit.is_rooted:
		_fail()
		return
	
	target = _get_closest_enemy()
	print(target)
	_move_random_target(target.global_position, _delta, true)
	if target == null or unit.global_position.distance_to(target.global_position) <= unit.aggro_range:
		_fail()
		return
	_running()
		

