extends Task
class_name smoke_bomb

func _run(_delta):
	var ability_ = unit.abilities[2].instantiate()
	ability_.name = 'Smoke Bomb'
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_.origin.get_tree().get_root().get_node('Main').add_child(ability_)
	ability_._use()
	_success()
