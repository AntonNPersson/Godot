extends Task
class_name use_ability

func _run(_delta):
	var summon = unit.abilities[0].instantiate()
	summon.unit = unit
	unit.add_child(summon)
	summon._use()
	_set_ability_on_cooldown(0)
	_success()
