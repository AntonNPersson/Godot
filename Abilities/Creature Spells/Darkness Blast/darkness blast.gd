extends Node
var target : Node
var origin : Node
var target_position : Vector2
var tag = null

@export var cast_duration : float
@export var cooldown : float = 10.0
@export var _range : float = 40
@export var size : float = 1.2
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
	var extra = {"ability": "Darkness blast",
				"Duration": 3}
	for i in range(0, values.size()):
		origin.do_action.emit(values[i], enemy, origin, tags[i], extra)

func _use():
	var callable = Callable(self, '_do_action')
	Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(size, cast_duration, origin.obstacles_info._get_random_walkable_tile(), origin, callable, after_effect)
