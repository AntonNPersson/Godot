extends Node2D
var origin
var target
var tag = null

@export var cast_duration : float = 2.0
@export var cooldown : float = 25.0
@export var _range : float = 100
@export var tags : Array = ["Wind", "Damage"]
@export var values : Array = [175.0, 40.0]
@export var cursed_branch_instance : PackedScene

@export var speed : float = 300
# Called when the node enters the scene tree for the first time.
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

func _use():
	origin.is_rooted = true
	Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(2.5, cast_duration, origin.global_position, origin, Callable(self, '_do_action'), cursed_branch_instance)
