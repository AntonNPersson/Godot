extends Task
class_name cast_acid_splash

func _run(_delta):
	var ability_ = unit.abilities[2].instantiate()
	cast_bar._start(ability_cooldowns[2])
	ability_.origin = unit
	ability_.add_to_group('projectiles')
	unit.add_child(ability_)
	ability_._use()
	_set_ability_on_cooldown(2)
	_success()
