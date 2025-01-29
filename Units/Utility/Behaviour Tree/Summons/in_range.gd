extends Task
class_name in_range

func _run(_delta):
	if !is_instance_valid(unit.target) or unit.target == null:
		_fail()
		return

	if unit.global_position.distance_to(unit.target.global_position) <= unit.aggro_range:
		unit.has_aggro = true
		get_child(0)._run(_delta)
	else:
		unit.has_aggro = false
		_fail()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
