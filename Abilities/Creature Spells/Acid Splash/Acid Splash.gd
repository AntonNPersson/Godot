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
var always_active = true

func _get_closest_target():
	var distance_to_target = 99999999
	if get_tree().get_nodes_in_group('players'):
		for child in get_tree().get_nodes_in_group('players'):
			var distance = origin.global_position.distance_to(child.global_position)
			
			if distance < distance_to_target:
				distance_to_target = distance
				return child
func _do_action(enemy):
	var extra = {"ability": "Acid Splash",
				"Duration": 2.0}
	for i in range(0, values.size()):
		origin.do_action.emit(values[i], enemy, origin, tags[i], extra)

func _process(delta):
	if origin == null:
		return
	if origin.dead:
		queue_free()

func _use():
	var callable = Callable(self, '_do_action')
	Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(size, cast_duration, origin.global_position, origin, callable, after_effect)
	

