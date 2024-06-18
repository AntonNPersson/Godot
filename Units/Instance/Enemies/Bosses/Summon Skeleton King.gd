extends Task
class_name summon_skeleton_king

func _run(_delta):
	var ability_ = unit.abilities[2].instantiate()
	cast_bar._start(ability_.cast_duration)
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_.origin.get_tree().get_root().get_node('Main').add_child(ability_)
	ability_._use()
	_set_ability_on_cooldown(2)
	_success()
