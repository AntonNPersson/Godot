extends Area2D
var damage
var direction
var speed
var origin
var target
var tag = "Damage"
var timer = 0
signal do_damage(damage, target, origin, tag)

func _process(delta):
	print('Cursed Spike')
	global_position += direction * speed * delta
	timer += delta
	if timer >= 10:
		queue_free()

func _on_area_entered(area:Area2D):
	if area.is_in_group('players'):
		do_damage.emit(damage, area, self, tag)
