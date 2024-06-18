extends Task
class_name run_away
@export var tile_range = 4.0
var tile_size = 128
var _range

func _run(_delta):
	_range = tile_range * tile_size
	_move_random_target(target.global_position, _delta)
	if timers[1] <= 0 or timers[3] <= 0:
		_success()
	else:
		_running()
		

