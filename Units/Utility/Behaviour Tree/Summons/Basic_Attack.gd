extends Task
class_name basic_attack
@export var tags : Array[String]
@export var values : Array[int]

func _run(_delta):
	if unit.is_stunned:
		_fail()
		return
	target = _get_closest_enemy()
	var base_frame_time = 1.0/2.0
	var animation_fps = base_frame_time * 7
	var speed_scale = animation_fps / unit.total_windup_time
	unit.get_node('AnimatedSprite2D').speed_scale = speed_scale/2
	update_sprite_direction(target.global_position, "Attack", false)
	attack_timer -= _delta
	_running()
	if attack_timer <= 0:
		unit.do_action.emit(unit.total_attack_damage, target, unit, "Damage")
		for u in range(tags.size()):
			unit.do_action.emit(values[u], target, unit, tags[u])

			if(tags[u] == "Bleed"):
				values[u] = unit.total_attack_damage * 0.2

		if unit.attack_modifier_tags.size() > 0:
			for i in range(unit.attack_modifier_tags.size()):
				unit.do_action.emit(unit.attack_modifier_values[i], target, unit, unit.attack_modifier_tags[i])
		attack_timer = unit.total_windup_time
		_success()

	if target == null:
		_fail()
		return

