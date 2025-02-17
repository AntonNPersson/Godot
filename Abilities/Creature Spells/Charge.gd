extends Area2D
var target
var origin
var target_position = Vector2(0,0)
var timer
var tag = null
var direction = Vector2(0,0)
@export var cast_duration = 3.0
@export var bonus_speed = 400
@export var tags = ['Damage', "Wind"]
@export var cooldown = 14.0
@export var values = [80, 100]
@export var _range = 1000
var original_speed
var original_position
var hit_enemies = []
var in_air = false
var is_hit = []
var extra = {"ability": "Charge",
			"Duration": 3}

func _process(delta):
	if in_air:
		if origin == null or !is_instance_valid(origin):
			_end()
			return
		origin.do_action.emit(-origin.total_speed, origin, 0.1, 'SpeedBuff', {"ability": "Charge", "Duration": 0.1})
		self.global_position = origin.global_position
		origin.global_position += direction * bonus_speed * delta
		Utility.get_node("AfterImages")._create_after_image(origin)
		_check_collision()

func _use():
	origin.do_action.emit(-origin.total_speed, origin, cast_duration, 'SpeedBuff', extra)
	await origin.get_tree().create_timer(cast_duration).timeout
	if origin == null or !is_instance_valid(origin):
		_end()
		return
	original_position = origin.global_position
	target_position = target.global_position
	if target.is_in_group("players") and target.get_node("Control").movement_target != null:
		target_position = target.global_position + target.get_node("Control").movement_target * 20
	direction = (target_position - self.global_position).normalized()
	origin.forced_animation_position = direction * _range
	in_air = true

func _end():
	queue_free()

func _check_collision():
	var overlapping = self.get_overlapping_areas()
	if original_position.distance_to(self.global_position) > _range:
		queue_free()
		return
	var extra = {"ability": "none"}
	for area in overlapping:
		if area.is_in_group('players') or area.is_in_group('player_summon'):
			if is_hit.has(area):
				continue
			for i in range(tags.size()):
				origin.do_action.emit(values[i], target, origin, tags[i], extra)
			is_hit.append(area)
		if area.is_in_group("obstacles"):
			origin.do_action.emit(4, origin, origin, "Stun", extra)
			get_child(1).visible = true
			get_child(1).play()
			in_air = false
			return
