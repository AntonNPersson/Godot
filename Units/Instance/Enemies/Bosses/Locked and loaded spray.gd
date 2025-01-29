extends Task
class_name locked_and_loaded_spray
var timer = 0
var used = false

func _run(_delta):
	var ability_ = unit.abilities[4].instantiate()
	if !cast_bar._start(ability_.cast_duration):
		ability_.queue_free()
		return
	ability_.origin = unit
	ability_.origin.get_tree().get_root().get_node('Main').get_node('Objects').add_child(ability_)

	if !used:
		ability_._use()
		used = true

	timer += _delta
	if timer > (ability_.num_projectiles * ability_.delay_between_projectiles) + 1:
		timer = 0
		used = false
		_set_ability_on_cooldown(4)
		_success()

