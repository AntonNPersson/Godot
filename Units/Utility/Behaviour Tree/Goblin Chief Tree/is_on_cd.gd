extends Task
class_name is_on_cd
@export var ability_index = 1
@export var change_state = false
@export var new_cooldown = 10.0

func _run(_delta):
	self.current_index = ability_index

	if change_state:
		_change_ability_cooldown(current_index, new_cooldown)
		change_state = false
	if timers[current_index] <= 0:
		get_child(0)._run(_delta)
		_running()
	else:
		_fail()
		
func _child_success():
	_success()

func _child_fail():
	_fail()
