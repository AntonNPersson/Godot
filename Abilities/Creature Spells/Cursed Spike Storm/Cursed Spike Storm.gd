extends Node2D
var origin
var target

@export var cast_duration : float = 3.0
@export var cooldown : float = 10.0
@export var _range : float = 400
@export var tags : Array = ["Damage"]
@export var values : Array = [0.0]
@export var cursed_spike_instance : PackedScene

@export var num_of_spikes : int = 8
@export var radius : float = 10
@export var speed : float = 300
# Called when the node enters the scene tree for the first time.

func _use():
	origin.is_rooted = true
	await origin.get_tree().create_timer(cast_duration).timeout
	if _check_if_dead(origin):
		queue_free()
		return
	var angle_increment = TAU / num_of_spikes
	for i in range(num_of_spikes):
		var angle: float = angle_increment * i
		var x: float = origin.global_position.x + radius * cos(angle)
		var y: float = origin.global_position.y + radius * sin(angle)
		var spike = cursed_spike_instance.instantiate()
		spike.global_position = Vector2(x, y)
		spike.direction = Vector2(cos(angle), sin(angle))
		spike.speed = speed
		spike.origin = origin
		spike.target = target
		spike.damage = values[0]
		spike.scale = Vector2(0.5, 0.5)
		spike.do_damage.connect(origin._on_do_action)
		spike.add_to_group('projectiles')
		origin.get_tree().get_root().get_node('Main').add_child(spike)
	origin.is_rooted = false

func _check_if_dead(unit):
	if !is_instance_valid(unit):
		return true
	if unit.is_queued_for_deletion():
		return true
	if unit.current_health <= 0:
		unit.is_dead.emit(unit)
		unit.set_meta('dying', true)
		return true
	return false

