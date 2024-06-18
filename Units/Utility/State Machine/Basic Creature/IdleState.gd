extends State
class_name IdleState
var path = null
var MAX_SPEED
var target_position = null
var test = true
var index = 0

func _action(_delta):
	super._action(_delta)
	if _unit.global_position.distance_to(_get_closest_target().global_position) < _unit.aggro_range or _unit.is_summon:
		_change_state.call('casting')

func _move(delta):
	while index < path.size():
		_unit.global_position.x = _linear_interpolate(_unit.global_position.x, path[index].x, delta)
		_unit.global_position.y = _linear_interpolate(_unit.global_position.y, path[index].y, delta)
		if _unit.global_position.distance_to(path[index]) < 1:
			index += 1
		break

func _move_random_target(_delta):
	if path == null:
		_update_path()

	var current = _unit.obstacles_info._walk_from_to(path, _unit, _delta, 2)
	if current > path.size() - 1 or current == -1:
		_update_path()

	if _unit.total_speed <= 0 and current != null:
		update_sprite_direction(path[current], "Walk", true)
	else:
		update_sprite_direction(path[current], "Walk", false)
	

func _update_path():
	path = _unit.obstacles_info._a_star(_unit.global_position, _get_closest_target(), "AllMoves")

func _linear_interpolate(start, end, weight):
		return start + (end - start) * weight
