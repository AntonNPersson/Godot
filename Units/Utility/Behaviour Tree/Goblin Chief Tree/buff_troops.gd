extends Task
class_name use_buff_ability

func _run(_delta):
	var summon = unit.abilities[2].instantiate()
	summon.unit = unit
	unit.add_child(summon)
	_success()
