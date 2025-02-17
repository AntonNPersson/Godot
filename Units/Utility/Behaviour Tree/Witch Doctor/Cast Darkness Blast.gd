extends Task
class_name cast_darkness_blast
var right = false

func _run(_delta):
	var ability_ = unit.abilities[3].instantiate()
	cast_bar._start(ability_cooldowns[3])
	ability_.origin = unit
	ability_.add_to_group('projectiles')
	unit.add_child(ability_)
	ability_._use()
	_set_ability_on_cooldown(3)
	_success()
