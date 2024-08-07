extends Node2D
var target : Node
var origin : Node
var target_position : Vector2
var tag = null
var cooldown = 5
var timer = 0
var enabled = false
var _range = 200

var units_in_range = []

@export var cast_duration : float
@export var heal : int

func _process(delta):
	timer += delta
	if enabled == false:
		return
	
	if !is_instance_valid(origin) or origin == null:
		queue_free()
		return
	
	if timer > 0.5:
		_get_units_in_range()
		for unit in units_in_range:
			unit.do_action.emit(heal, unit, origin, "Heal")
		timer = 0
	global_position = origin.global_position

func _use():
	print("Healing Aura used")
	global_position = origin.global_position
	enabled = true
	cooldown = 9999

func _get_units_in_range():
	units_in_range = []
	for unit in origin.get_tree().get_nodes_in_group("enemies"):
		if unit.global_position.distance_to(global_position) < _range:
			units_in_range.append(unit)
		else:
			units_in_range.erase(unit)
