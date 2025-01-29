extends Area2D
var unit : Node
var target_position : Vector2
var damage
var values = []
@export var speed = 1300
var is_critical = false
var tag = "Damage"
var tags = []
signal do_damage(damage, target, this, tag, extra)

# Called when the node enters the scene tree for the first time.
func _process(delta):
	_check_collision()
	global_position += target_position * speed * delta

func _do_damage(target):
	var extra = {}

	extra = {"basic_attacking": true, "critical": is_critical, "ability" : null}
	do_damage.emit(damage, target, unit, tag, extra)
	if tags.size() > 0:
		for i in range(tags.size()):
			if i < unit.current_attack_modifier_abilities.size():
				extra = {"basic_attacking": true, "critical": is_critical, "ability" : unit.current_attack_modifier_abilities[i]}
				do_damage.emit(values[i], target, unit, tags[i], extra)
	queue_free()

func _check_collision():
	var overlapping = self.get_overlapping_areas()
	for area in overlapping:
		if area.is_in_group("enemies"):
			_do_damage(area)
			return
		if area.is_in_group("obstacles"):
			queue_free()
			return
	
