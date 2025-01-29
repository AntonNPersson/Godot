extends Node
var target : Node
var origin : Node
var target_position : Vector2
var tag = null

@export var cast_duration : float
@export var cooldown : float = 2.0
@export var size : float
@export var tags : Array = ["Damage"]
@export var values : Array = [0.0]
@export var after_effect : PackedScene

func _get_closest_target():
	var distance_to_target = 99999999
	if origin.get_tree().get_nodes_in_group('enemies'):
		for child in origin.get_tree().get_nodes_in_group('enemies'):
			var distance = origin.global_position.distance_to(child.global_position)
			
			if distance < distance_to_target:
				distance_to_target = distance
				return child

func _initialize_ability(unit):
	origin = unit
	target = _get_closest_target()
	target_position = target.global_position

func _do_action(enemy):
	var extra = {"ability": "Meteor"}
	for i in range(0, values.size()):
		if origin.globals.has(tags[i]):
			origin.do_action.emit((values[i] * origin.summon_level) + ((values[i] * origin.summon_level) * (origin.globals[tags[i]]/100.0)), enemy, origin, tags[i], extra)
		else:
			origin.do_action.emit((values[i] * origin.summon_level), enemy, origin, tags[i], extra)

func _use():
	var callable = Callable(self, '_do_action')
	Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(size, cast_duration, target_position, origin, callable, after_effect, true)
