extends Area2D
var unit : Node
var damage
var values = []
@export var speed = 1300
var has_hit_target = false
var is_critical = false
var tag = "Damage"
var tags = []
signal do_damage(damage, target, this, tag, extra)

# Called when the node enters the scene tree for the first time.
func _process(delta):
	if not has_hit_target and is_instance_valid(unit):
		if global_position.distance_to(unit.global_position) <= 10:
			global_position = unit.global_position
			_do_damage()
		else:
			global_position += (unit.global_position - global_position).normalized() * speed * delta
			rotation = (unit.global_position - global_position).angle()
			scale = Vector2(0.55, 0.55)
	elif !is_instance_valid(unit):
		queue_free()

func _do_damage():
	if not has_hit_target:
		has_hit_target = true
		var extra = {"basic_attacking": true, "critical": is_critical}
		do_damage.emit(damage, unit, self, tag, extra)
		if tags.size() > 0:
			for i in range(tags.size()):
				do_damage.emit(values[i], unit, self, tags[i])
	queue_free()
