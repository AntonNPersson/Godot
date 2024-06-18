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
func _summon_died(_unit):
	current_summons -= 1
	
func _ready():
	current_summons = summons.size()
	
func _use():
	temp_name += 1
	if !unit.summoned:
		for child in summons:
			var instanced = child.instantiate()
			var effect = summon_effect.instantiate()
			unit.get_node('Summons').add_child(instanced)
			instanced.add_child(effect)
			instanced.global_position = unit.obstacles_info._get_random_spawn_position()
			effect.global_position = instanced.global_position
			effect.get_child(0).restart()
			effect.get_child(0).emitting = true
			instanced.obstacles_info = unit.obstacles_info
			instanced.drop_info = unit.drop_info
			instanced.do_action.connect(unit._on_do_action)
			instanced.is_dead.connect(_summon_died)
			instanced.name = str(temp_name)
			instanced.is_summon = true
		unit.summoned = true

func _process(_delta):
	if current_summons <= 0 and unit:
		unit.summoned = false
		self.queue_free()
