extends Task
class_name check_cooldowns

func _run(_delta):
	if unit.abilities.size() == 0:
		_fail()
		return
	for a in unit.abilities.size():
		if !unit._check_if_on_cooldown_player_summon(a):
			unit._set_current_ability(a)
			get_child(0)._run(_delta)
			_running()
			return
	_fail()
