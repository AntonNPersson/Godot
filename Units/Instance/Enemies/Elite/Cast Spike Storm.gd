extends Task
class_name cast_spike_storm

func _run(_delta):
	var ability_ = unit.abilities[1].instantiate()
	if !cast_bar._start(ability_.cast_duration):
		_fail()
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_._use()
	ability_.add_to_group('projectiles')
	ability_.origin.get_tree().get_root().get_node('Main').add_child(ability_)
	_set_ability_on_cooldown(1)
	_success()