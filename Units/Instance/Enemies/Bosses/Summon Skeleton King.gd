extends Task
class_name summon_skeleton_king
var once = false

func _run(_delta):
	if once:
		_fail()
		return
	var ability_ = unit.abilities[2].instantiate()
	cast_bar._start(ability_.cast_duration)
	ability_.unit = unit
	ability_._use()
	once = true
	_set_ability_on_cooldown(2)
	_success()
