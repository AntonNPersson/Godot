extends Task
class_name throw_potion_improved
var after_effect_type = {"big": false,
	"small": false}

func _run(_delta):

	var ability_ = unit.abilities[1].instantiate()
	ability_.origin = unit
	ability_.target = _get_closest_target()
	ability_.origin.get_tree().get_root().get_node('Main').add_child(ability_)
	if !unit.summoned:
		ability_.improved = false
		var random_position = unit.obstacles_info._get_random_walkable_tile()
		var closest_target_position = _get_closest_target().global_position

		var direction_to_target = (closest_target_position - random_position).normalized()
		var adjusted_position = random_position + direction_to_target * 100

		ability_.target_position = adjusted_position
		ability_.size = 2
		_change_ability_cooldown(1, 0.8)
	else:
		ability_.improved = true
		ability_.target_position = _get_closest_target().global_position
		ability_.size = 1
		_change_ability_cooldown(1, 0.4)

	ability_._use()
	_set_ability_on_cooldown(1)
	_running()
