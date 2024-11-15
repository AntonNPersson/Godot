extends State
class_name CastingState


func _action(_delta):
	if _unit.is_stunned or _unit.is_frozen or get_tree().get_first_node_in_group("players").in_stealth:
		_interrupt_cast_timer()
		return
	if _unit.abilities.size() - 1 >= 0:
		var ability_ = _unit.abilities[current_index].instantiate()
		_start_cast_bar(ability_.cast_duration)
		if ability_.tag != null:
			match ability_.tag:
				'SpeedBuff':
					ability_.target = _unit
				'Damage':
					ability_.target = _get_closest_target()
					ability_.origin = _unit
					ability_.global_position = _unit.global_position
					ability_.do_damage.connect(_unit._on_do_action)
				'Infected':
					ability_.origin = _unit
		else:
			ability_.target = _get_closest_target()
			ability_.origin = _unit
			ability_.global_position = _unit.global_position

		ability_.add_to_group('projectiles')			
		_unit.get_tree().get_root().get_node('Main').add_child(ability_)
		ability_._use()
		_set_ability_on_cooldown(current_index)
		_change_state.call('chasing')

func _on_cast_end():
	cast_bar.visible = false
	is_casting = false
