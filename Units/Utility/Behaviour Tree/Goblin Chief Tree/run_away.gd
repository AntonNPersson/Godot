extends Task
class_name run_away
@export var tile_range = 4.0
var tile_size = 128
var _range

func _run(_delta):
	_range = tile_range * tile_size
	target = _get_closest_target()
	_move_random_target(target.global_position, _delta)
	_success()
		

