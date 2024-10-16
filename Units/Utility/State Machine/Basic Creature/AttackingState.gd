extends State
class_name AttackingState
var attack_timer
var _is_winding = true
# Called when the node enters the scene tree for the first time.
func _ready():
	attack_timer = _unit.total_windup_time
	
func _action(_delta):
	if _unit.is_stunned or _unit.is_frozen or get_tree().get_first_node_in_group("players").in_stealth:
		_interrupt_cast_timer()
		return
	var separation_vector = Vector2()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy != _unit:
			var enemy_position = enemy.global_position
			var separation = _unit.global_position.distance_to(enemy_position)
			if separation < 30:
				separation_vector += (_unit.global_position - enemy_position).normalized() * (30 - separation)
	_unit.global_position += separation_vector * _delta * 2
	for i in range(ability_cooldowns.size()):
		if !_is_ability_on_cooldown(i):
			_is_winding = false
			return _change_state.call('casting')
		break
	update_sprite_direction(_get_closest_target().global_position, "Attack", false)
	if _unit.global_position.distance_to(_get_closest_target().global_position) > _unit.total_range + 60 and attack_timer >= (_unit.total_windup_time * 0.15):
		return _change_state.call('chasing')
	if _unit.total_range < 200:
		if _is_winding:
			attack_timer -= _delta
			if attack_timer <= 0.0:
				_unit.do_action.emit(_unit.total_attack_damage, _get_closest_target(), _unit, "Damage")
				if _unit.attack_modifier_tags.size() > 0:
					for i in range(_unit.attack_modifier_tags.size()):
						_unit.do_action.emit(_unit.attack_modifier_values[i], _get_closest_target(), _unit, _unit.attack_modifier_tags[i])
				attack_timer = _unit.total_windup_time
				_is_winding = false
				for i in range(ability_cooldowns.size()):
					if !_is_ability_on_cooldown(i):
						return _change_state.call('casting')
				return _change_state.call('chasing')
		else:
			attack_timer = _unit.total_windup_time
			_is_winding = true
			return
	else:
		if _is_winding:
			attack_timer -= _delta
			if attack_timer <= 0.0:
				var instance = _unit.basic_attack_scene.instantiate()
				get_tree().get_root().add_child(instance)
				instance.do_damage.connect(_unit._on_do_action)
				instance.global_position = _unit.global_position
				instance.unit = _get_closest_target()
				instance.damage = _unit.total_attack_damage
				instance.tags = _unit.attack_modifier_tags
				attack_timer = _unit.total_windup_time
				_is_winding = false
				for i in range(ability_cooldowns.size()):
					if _is_ability_on_cooldown(i):
						return _change_state.call('casting')
				return _change_state.call('chasing')
		else:
			attack_timer = _unit.total_windup_time
			_is_winding = true
			for i in range(ability_cooldowns.size()):
				if _is_ability_on_cooldown(i):
					return _change_state.call('casting')
			return
		
	
