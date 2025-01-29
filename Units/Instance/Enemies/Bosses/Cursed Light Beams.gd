extends Task
class_name cursed_light_beams

func _run(_delta):
	var ability_ = unit.abilities[0].instantiate()
	if !cast_bar._start(ability_.cast_duration):
		ability_.queue_free()
		return _fail()
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_.origin.get_tree().get_root().get_node('Main').add_child(ability_)
	ability_._use()
	_set_ability_on_cooldown(0)
	_success()
