extends Task
class_name throw_potion_improved

func _run(_delta):

	var ability_ = unit.abilities[1].instantiate()
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_.origin.get_tree().get_root().get_node('Main').add_child(ability_)
	if !unit.summoned:
		ability_.target_position = unit.obstacles_info._get_random_walkable_tile()
		ability_.size = 3
		_change_ability_cooldown(1, 1.1)
		cast_bar._start(ability_cooldowns[1])
	else:
		ability_.target_position = _get_closest_target().global_position
		ability_.size = 1
		_change_ability_cooldown(1, 0.55)
		cast_bar._start(ability_cooldowns[1])

	ability_._use()
	_set_ability_on_cooldown(1)
	_running()
