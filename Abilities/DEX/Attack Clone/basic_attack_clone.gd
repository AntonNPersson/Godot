extends Task
class_name basic_attack_clone
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
		var player = unit.get_tree().get_nodes_in_group("players")[0]
		var instance = unit.basic_attack_scene.instantiate()
		instance.do_damage.connect(unit._on_do_action)
		instance.global_position = unit.global_position
		instance.unit = unit._target
		instance.original_unit = unit
		instance.damage = player.total_attack_damage
		instance.tags = tags
		instance.values = values
		unit.get_tree().get_root().add_child(instance)
		
		attack_timer = player.total_windup_time
		update_sprite_direction(unit._target.global_position, "Walk", false, attack_timer)
		_fail()
		return
