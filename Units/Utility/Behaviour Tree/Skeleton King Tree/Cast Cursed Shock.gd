extends Task
class_name cast_cursed_shock

func _run(_delta):
	var ability_ = unit.abilities[0].instantiate()
	if !cast_bar._start(ability_cooldowns[0]):
		_fail()
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_.add_to_group('projectiles')
	ability_._use()
	ability_.queue_free()
	_set_ability_on_cooldown(0)
	_success()
