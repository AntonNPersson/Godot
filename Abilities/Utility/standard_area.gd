extends Area2D
var origin
var target = Vector2.ZERO
var move = false
var _range
var speed
var direction
var caster
var _radius
var _duration
var trigger_always
signal has_hit(unit, extra)
var hit_enemies = []
var angle_to_target
var _type
var current_type
var pool_effect
var area_pool
var area_pool_radius
var extra = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _start(vector, distance, velocity, unit, radius, duration, type, color = Color(1, 1, 1, 1), always = false, sprite_frames = null, sprite_scale = 1, pool = false, pool_radius = 0, echo = 0, ability = null):
	speed = velocity
	target = vector
	_range = distance
	caster = unit
	_radius = radius
	_duration = duration
	area_pool = pool
	origin = ability
	area_pool_radius = pool_radius
	pool_effect = load("res://Abilities/Utility/pool.tscn")
	_type = type
	trigger_always = always
	if echo > 0:
		extra['Echo'] = 0.4
		print('Echo')
	if global_position.distance_to(target) > _range:
		global_position = global_position.lerp(target, _range/global_position.distance_to(target))
	else:
		global_position = target
	get_child(2).color = color
	get_child(2).color.a = 0.7
	get_child(2).texture_scale = 0.1

	if type == 0:
		get_child(0).color = color
		get_child(0).modulate = color
		get_child(0).emission_sphere_radius = radius/1.5
		current_type = get_child(0)
	if type == 1:
		get_child(3).color = color
		get_child(3).modulate = color
		get_child(3).emission_sphere_radius = radius
		get_child(3).initial_velocity_min = radius * ((1/duration))
		get_child(3).lifetime = duration
		# 300 * (1/0.4) 
		current_type = get_child(3)
	if type == 2:
		get_child(4).color = color
		get_child(4).modulate = color
		get_child(4).initial_velocity_min = radius * ((1/duration))
		get_child(4).lifetime = duration
		current_type = get_child(4)
	if type == 3:
		if sprite_frames != null:
			get_child(5).sprite_frames = sprite_frames
			get_child(5).scale = Vector2(sprite_scale, sprite_scale)
			get_child(5).play()
			current_type = get_child(5)
	get_child(1).shape.radius = radius * 0.8
	_cast_area()

func _process(_delta):
	if trigger_always:
		_check_collision()

func _cast_area():
	current_type.visible = true
	if current_type != get_child(5):
		current_type.restart()
		current_type.emitting = true
	var timer = Timer.new()
	timer.set_wait_time(_duration)
	timer.set_one_shot(true)
	timer.timeout.connect(_remove_area)
	add_child(timer)
	timer.start()

func _remove_area():
	current_type.visible = false
	if current_type != get_child(5):
		current_type.emitting = false
	get_child(2).texture_scale = _radius/100
	if area_pool:
		var __explosion = pool_effect.instantiate()
		__explosion.global_position = target
		__explosion.get_node('particle').color = get_child(2).color
		__explosion.get_node('particle').emitting = true
		__explosion.get_node('Sprite2D').modulate = get_child(2).color
		__explosion.has_hit.connect(origin._on_hit)
		get_tree().get_root().get_node('Main').add_child(__explosion)
	if !trigger_always:
		_check_collision()
	queue_free()

func _check_collision():
	var overlapping = self.get_overlapping_areas()
	
	for area in overlapping:
		if area.is_in_group('enemies') and area not in hit_enemies:
			hit_enemies.append(area)
			has_hit.emit(area, extra)
