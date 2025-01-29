extends Task
class_name idle
@export var combat_idle = false

func _run(_delta):
	update_sprite_direction(_get_closest_target().global_position, "Walk", true)
	if combat_idle:
		if !is_instance_valid(unit._target) or unit._target == null or !unit._target.is_in_group("enemies"):
			target = _get_closest_enemy()
	_success()	
		
func _child_success():
	_success()

func _child_fail():
	_fail()
