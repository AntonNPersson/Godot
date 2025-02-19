extends Node
var target : Node
var origin : Node
var target_position : Vector2
var tag = null
var improved = false

@export var cast_duration : float
@export var cooldown : float = 2.0
@export var range : float
@export var size : float
@export var tags : Array = ["Damage"]
@export var values : Array = [0.0]
@export var after_effect : PackedScene
@export var after_effect_1 : PackedScene

func _ready():
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
func _do_action(enemy):
	for i in range(0, values.size()):
		origin.do_action.emit(values[i], enemy, origin, tags[i])
	queue_free()

func _process(delta):
	cast_duration = cooldown
	if origin == null:
		return
	if origin.dead:
		queue_free()

func _use():
	origin.do_action.emit(-origin.total_speed, origin, cast_duration, 'SpeedBuff')
	var callable = Callable(self, '_do_action')
	if !improved:
		Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(size, cast_duration, target_position, origin, callable, after_effect)
	else:
		Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(size, cast_duration, target_position, origin, callable, after_effect_1)
