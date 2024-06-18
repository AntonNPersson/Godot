extends Node
var target : Node
var origin : Node
var target_position : Vector2
var tag = null

@export var cast_duration : float
@export var cooldown : float = 2.0
@export var range : float
@export var size : float
@export var tags : Array = ["Damage"]
@export var values : Array = [0.0]
@export var after_effect : PackedScene

func _ready():
	cooldown = cast_duration
	var af = after_effect.instantiate()
	af.scale = Vector2(size, size)
	target_position = target.global_position

func _get_closest_target():
	var distance_to_target = 99999999
	if get_tree().get_nodes_in_group('players'):
		for child in get_tree().get_nodes_in_group('players'):
			var distance = origin.global_position.distance_to(child.global_position)
			
			if distance < distance_to_target:
				distance_to_target = distance
				return child
func _do_action():
	for i in range(0, values.size()):
		origin.do_action.emit(values[i], _get_closest_target(), origin, tags[i])
	queue_free()

func _process(delta):
	cast_duration = cooldown
	if origin == null:
		return
	if origin.dead:
		queue_free()

func _use():
	var callable = Callable(self, '_do_action')
	var pos = origin.obstacles_info._get_special_positions()
	var bad_pos = pos[0]
	pos.shuffle()
	
	var used_positions = 0
	for i in range(pos.size()):
		if pos[i] != bad_pos:
			Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(size, cast_duration, pos[i], origin, callable, after_effect)
			used_positions += 1
			if used_positions >= 2:
				break

	if used_positions < 2:
		print("Not enough valid positions found.")

