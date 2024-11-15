extends Area2D
var duration
var speed = 50
var origin
var target
var tag = null
var cooldown = 5
var cast_duration = 1.0
var _range = 500

func _process(delta):
	var direction = (target.global_position - global_position).normalized()

	var current_direction = global_transform.basis_xform(Vector2.RIGHT).normalized()
	var new_direction = current_direction.lerp(direction, 0.01)

	global_position += new_direction * speed * delta
	_check_collision()

func _check_collision():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group('players'):
			target.get_node('Control').on_action.emit(duration, area, target, "Root")
			queue_free()
		if area.is_in_group('obstacles'):
			queue_free()
