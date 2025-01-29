extends Task
class_name teleport_to_player

func _run(_delta):
	if unit.global_position.distance_to(_get_closest_target().global_position) <= 10:
		_fail()
	_move_random_target(_get_closest_target().global_position, _delta)
	_running()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
