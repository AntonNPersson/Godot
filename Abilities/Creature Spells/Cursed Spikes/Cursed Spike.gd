extends Area2D
var damage
var direction
var speed
var origin
var target
var tag = "Damage"
signal do_damage(damage, target, origin, tag)

func _process(delta):
	global_position += direction * speed * delta

func _on_area_entered(area:Area2D):
	if area.is_in_group('players'):
		do_damage.emit(damage, area, self, tag)
	if area.is_in_group('obstacles'):
		queue_free()