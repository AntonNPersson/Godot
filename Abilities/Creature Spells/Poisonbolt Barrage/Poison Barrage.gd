extends Node2D
var target
var origin
var mm
var right = false
@export var cast_duration : float = 0.2
@export var cooldown : float = 1.2
@export var _range : float = 0
@export var poison_bolt_instance : PackedScene
var is_shooting = false
var duration = 20.0
@export var cast_interval = 1.5
var cast_timer = 0.0
var always_active = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	cast_timer += delta
	duration -= delta
	if duration <= 0 or mm == null:
		is_shooting = false
		queue_free()
		return

	if is_shooting and cast_timer >= cast_interval:
		var bolt = poison_bolt_instance.instantiate()
		if right:
			bolt.global_position = mm._get_random_right_witch_doctor_spawn()
			target = bolt.global_position + Vector2.LEFT * 1000
		else:
			bolt.global_position = mm._get_random_left_witch_doctor_spawn()
			target = bolt.global_position + Vector2.RIGHT * 1000
		bolt.origin = origin
		bolt.target_position = target
		origin.get_tree().get_root().get_node('Main').add_child(bolt)
		bolt.add_to_group('projectiles')
		bolt._use()
		print('poison bolt')
		cast_timer = 0.0

func _use():
	is_shooting = true
