extends Task
class_name in_range

func _run(_delta):
	target = _get_closest_enemy()
	if target == null:
		_fail()
		return
	
	if unit.global_position.distance_to(target.global_position) <= unit.aggro_range:
		unit.has_aggro = true
		get_child(0)._run(_delta)
		_running()
	else:
		unit.has_aggro = false
		_fail()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
