extends Node
var target : Node
var origin : Node
var target_position : Vector2
var tag = null

@export var cast_duration : float
@export var cooldown : float = 10.0
@export var _range : float = 40
@export var sizes : Array = [0.4, 0.8, 1.2]
@export var tags : Array = ["Damage"]
@export var values : Array = [0.0]
@export var after_effect : PackedScene

func _get_closest_target():
	var distance_to_target = 99999999
	if get_tree().get_nodes_in_group('players'):
		for child in get_tree().get_nodes_in_group('players'):
			var distance = origin.global_position.distance_to(child.global_position)
			
			if distance < distance_to_target:
				distance_to_target = distance
				return child
func _do_action(enemy):
	for i in range(0, values.size()):
		origin.do_action.emit(values[i], enemy, origin, tags[i])

func _last_do_action(enemy):
	for i in range(0, values.size()):
		origin.do_action.emit(values[i], enemy, origin, tags[i])
	queue_free()

func _use():
	var target_pos = _get_closest_target().global_position
	var extra = {"ability": "Darkness echo",
				"Duration": cast_duration * 3}
	origin.do_action.emit(-origin.total_speed, origin, cast_duration * 3, 'SpeedBuff', extra)
	var callable = Callable(self, '_do_action')
	var last_callable = Callable(self, '_last_do_action')
	Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(sizes[0], cast_duration, target_pos, origin, callable, after_effect)
	await get_tree().create_timer(cast_duration).timeout
	if !is_instance_valid(origin):
		queue_free()
		return
	Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(sizes[1], cast_duration, target_pos, origin, callable, after_effect)
	await get_tree().create_timer(cast_duration).timeout
	if !is_instance_valid(origin):
		queue_free()
		return
	Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(sizes[2], cast_duration, target_pos, origin, last_callable, after_effect)
