extends Task
class_name use_ability_2

func _run(_delta):
	var summon = unit.abilities[3].instantiate()
	summon.unit = unit
	unit.add_child(summon)
	summon._use()
	unit.summoned = true
	_success()
