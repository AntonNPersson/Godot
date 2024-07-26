extends Task
class_name double_heavy_attack

func _run(_delta):
	var ability_ = unit.abilities[0].instantiate()
	if !cast_bar._start(ability_cooldowns[0]):
		_fail()
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_.add_to_group('projectiles')
	ability_._use()
	unit.get_tree().get_root().get_node('Main').add_child(ability_)
	_set_ability_on_cooldown(0)
	_success()
