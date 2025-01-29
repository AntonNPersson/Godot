extends Task
class_name cast_ability

func _run(_delta):
	if unit.is_stunned:
		_fail()
		return
	print("Casting ability")
	var instance = unit.abilities[unit.current_ability_index].instantiate()
	instance._initialize_ability(unit)
	instance._use()
	unit.get_tree().get_root().add_child(instance)
	unit._set_on_cooldown_player_summon(unit.current_ability_index)
	_fail()
	return
