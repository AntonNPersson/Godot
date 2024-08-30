extends Task
class_name idle

func _run(_delta):
	update_sprite_direction(_get_closest_target().global_position, "Walk", true)
	_success()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
