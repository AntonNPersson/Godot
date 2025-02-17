extends Task
class_name summon_scientists

func _run(_delta):
	var summon = unit.abilities[1].instantiate()
	summon.unit = unit
	unit.add_child(summon)
	summon._use()
	_set_ability_on_cooldown(1)
	_success()
