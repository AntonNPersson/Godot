extends Task
class_name cast_poison_barrage
var right = false

func _run(_delta):
	var ability_ = unit.abilities[0].instantiate()
	cast_bar._start(ability_cooldowns[0])
	right = !right
	ability_.right = right
	ability_.origin = unit
	ability_.mm = unit.obstacles_info
	ability_.add_to_group('projectiles')
	unit.add_child(ability_)
	ability_._use()
	print('poison barrage')
	_set_ability_on_cooldown(0)
	print("finished")
	_success()
