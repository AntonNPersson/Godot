extends Area2D
var duration
var speed = 20
var origin
var target
var tag = null
var cooldown = 5
var cast_duration = 1.0
var _range = 500

func _process(delta):
	var direction = (target.global_position - global_position).normalized()
	var angle_to_target = direction.angle()
	global_rotation = lerp_angle(global_rotation, angle_to_target, 0.05)

	var forward = Vector2(cos(rotation), sin(rotation))
	global_position += forward * speed * delta

	_check_collision()

func _check_collision():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group('players'):
			target.get_node('Control').on_action.emit(duration, area, target, "Root")
			queue_free()
		if area.is_in_group('obstacles'):
			queue_free()
