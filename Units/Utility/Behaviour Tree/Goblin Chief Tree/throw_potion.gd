extends Task
class_name throw_potion

func _run(_delta):
	var ability_ = unit.abilities[1].instantiate()
	cast_bar._start(ability_cooldowns[1])
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_.origin.get_tree().get_root().get_node('Main').get_node('Objects').add_child(ability_)
	ability_._use()
	_set_ability_on_cooldown(1)
	_success()

