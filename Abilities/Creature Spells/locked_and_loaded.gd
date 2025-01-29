extends Area2D
var target
var origin
var target_position = Vector2(0,0)
var timer
var direction = Vector2(0,0)
@export var cast_duration = 2.0
@export var channel_duration = 2.0
@export var bonus_speed = 200
@export var tag = 'Damage'
@export var cooldown = 8.0
@export var damage = 40
@export var _range = 1000
signal do_damage(damage, target, this, tag)
var original_speed
var original_position
var hit_enemies = []
var in_air = false
var is_hit = []

func _use():
	timer = Timer.new()
	timer.timeout.connect(_on_timeout)
	timer.set_wait_time(channel_duration)
	original_speed = origin.bonus_speed
	original_position = origin.global_position
	origin.bonus_speed = -origin.base_speed
	add_child(timer)
	timer.start()
	direction = (target_position - self.global_position).normalized()
	self.rotation = direction.angle()
	get_node('Sprite2D').visible = true
	get_node('Sprite2D').play('channel')
	get_node('Sprite2D').animation_finished.connect(_on_channel_finished)

func _on_channel_finished():
	get_node('Sprite2D').animation_finished.disconnect(_on_channel_finished)
	get_node('Sprite2D').play('air')

func _on_hit_finished():
	queue_free()
	
func _on_timeout():
	if target_position == Vector2(0, 0):  # Check if target_position has not been set
		target_position = target.global_position
		if target.is_in_group("players") and target.get_node("Control").movement_target != null:
			target_position = target.global_position + target.get_node("Control").movement_target * 20

		direction = (target_position - self.global_position).normalized()
		self.global_position += direction * 20
		self.rotation = direction.angle()
		self.visible = true
		in_air = true
		if is_instance_valid(origin):
			origin.bonus_speed = original_speed
		timer.stop()
	
func _physics_process(delta):
	_check_if_caster_died(origin)
	_check_collision()
	if in_air:
		self.global_position += direction * bonus_speed * delta

func _check_if_caster_died(_origin):
	if !is_instance_valid(_origin):
		queue_free()

func _check_collision():
	var overlapping = self.get_overlapping_areas()
	if original_position.distance_to(self.global_position) > _range:
		get_node('Sprite2D').play('hit')
		if !get_node('Sprite2D').animation_finished.is_connected(_on_hit_finished):
			get_node('Sprite2D').animation_finished.connect(_on_hit_finished)
		return

	for area in overlapping:
		if area.is_in_group('players') or area.is_in_group('player_summon'):
			if is_hit.has(area):
				continue
			do_damage.emit(damage, area, self, tag)
			get_node('Sprite2D').play('hit')
			is_hit.append(area)
			if !get_node('Sprite2D').animation_finished.is_connected(_on_hit_finished):
				get_node('Sprite2D').animation_finished.connect(_on_hit_finished)
			return
