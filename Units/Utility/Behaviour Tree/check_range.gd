extends Task
class_name is_out_of_range
@export var tile_range = 3.0
var _range
@export var reverse = false
var tile_size = 128

func _run(_delta):
	_range = tile_range * tile_size
	if reverse:
		if unit.global_position.distance_to(_get_closest_target().global_position) <= _range:
			get_child(0)._run(_delta)
			_running()
		else:
			_fail()
	else:
		if unit.global_position.distance_to(_get_closest_target().global_position) >= _range:
			get_child(0)._run(_delta)
			_running()
		else:
			_fail()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
