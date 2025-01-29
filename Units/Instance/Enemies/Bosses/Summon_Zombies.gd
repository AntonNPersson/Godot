extends Task
class_name summon_zombies

func _run(_delta):
	var ability_ = unit.abilities[1].instantiate()
	if !cast_bar._start(ability_.cast_duration):
		ability_.queue_free()
		return _fail()
	ability_.unit = unit
	unit.get_tree().get_root().get_node('Main').add_child(ability_)
	ability_._use()
	_set_ability_on_cooldown(1)
	_success()
