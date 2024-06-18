extends Task
class_name remove_smoke_bomb

func _run(_delta):
	var ability_ = unit.get_tree().get_root().get_node('Main').get_node('Smoke Bomb')
	ability_._unuse()
	_success()
