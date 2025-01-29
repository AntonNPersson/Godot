extends Task
class_name basic_attack
@export var tags : Array[String]
@export var values : Array[int]

func _run(_delta):
	if unit.is_stunned:
		_fail()
		return
	attack_timer -= _delta
	_running()
	update_sprite_direction(unit._target.global_position, "Attack", false, attack_timer)
	if attack_timer <= 0:
		if unit.total_attack_damage > 0:
			unit.do_action.emit(unit.total_attack_damage, unit._target, unit, "Damage")
		for u in range(tags.size()):
			if unit.globals.has(tags[u]):
				unit.do_action.emit(values[u] + (values[u] * (unit.globals[tags[u]]/100.0)), unit._target, unit, tags[u])
			else:
				unit.do_action.emit(values[u], unit._target, unit, tags[u])

		if unit.attack_modifier_tags.size() > 0:
			for i in range(unit.attack_modifier_tags.size()):
				unit.do_action.emit(unit.attack_modifier_values[i], unit._target, unit, unit.attack_modifier_tags[i])
		attack_timer = unit.total_windup_time
		update_sprite_direction(unit._target.global_position, "Walk", false, attack_timer)
		_fail()
		return
