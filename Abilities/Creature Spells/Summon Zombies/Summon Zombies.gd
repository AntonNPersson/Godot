extends Node2D
var troop
var unit
var current_summons = 1
@export var cast_duration = 0.0
@export var cooldown = 4.0
@export var summons:Array[PackedScene] = []
@export var summon_effect : PackedScene
var temp_name = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func _use():
	temp_name += 1
	for child in summons:
		var instanced = child.instantiate()
		var effect = summon_effect.instantiate()
		unit.get_node('Summons').add_child(instanced)
		instanced.add_child(effect)
		instanced.global_position = unit.obstacles_info._get_random_walkable_tile()
		effect.global_position = instanced.global_position
		effect.get_child(0).restart()
		effect.get_child(0).emitting = true
		instanced.obstacles_info = unit.obstacles_info
		instanced.drop_info = unit.drop_info
		instanced.do_action.connect(unit._on_do_action)
		instanced.name = str(temp_name)
		instanced.is_summon = true
		instanced.add_to_group('summons')
		instanced.add_to_group('enemies')
		instanced.paused = false
		instanced.has_aggro = true
		unit.summoned = true
	queue_free()