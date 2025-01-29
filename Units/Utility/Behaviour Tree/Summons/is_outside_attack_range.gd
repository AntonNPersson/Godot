extends Task
class_name outside_attack_range

func _run(_delta):
	if !is_instance_valid(unit._target) or unit._target == null:
		_success()
		return
	if unit.global_position.distance_to(unit._target.global_position) > unit.total_range:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
