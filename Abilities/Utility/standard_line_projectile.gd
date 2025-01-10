extends Area2D
var origin
var target = Vector2.ZERO
var move = false
var _range
var speed
var direction
var caster
var start_pos
signal has_hit(unit)
var hit_enemies = []
var angle_to_target
var pierce = false
var explosion_instance
var explosion_color
var explosion = false
var explosion_radius = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if move:
		if self.global_position.distance_to(caster) >= _range:
			queue_free()
		_check_collision()
		self.rotation = move_toward(rotation, angle_to_target, delta * 100)
		self.global_position += direction * speed * delta

func _start(vector, distance, velocity, unit, sprite_frames: SpriteFrames, collision_radius, light_size, light_color, sprite_scale, _pierce, _explosion, _explosion_radius, _origin):
	speed = velocity
	target = vector
	_range = distance
	caster = unit
	pierce = _pierce
	start_pos = unit
	origin = _origin
	get_child(0).shape.radius = collision_radius
	get_child(1).sprite_frames = sprite_frames
	self.scale = Vector2(sprite_scale, sprite_scale)
	get_child(2).color = light_color
	get_child(2).texture_scale = light_size
	direction = (target - self.global_position).normalized()
	angle_to_target = atan2(target.y - self.global_position.y, target.x - self.global_position.x)
	explosion_instance = load('res://Abilities/Utility/explosion.tscn')
	explosion_radius = _explosion_radius
	explosion_color = light_color
	explosion = _explosion
		
	move = true

func _check_collision():
	var overlapping = self.get_overlapping_areas()
	
	for area in overlapping:
		if start_pos.distance_to(caster) > _range:
			queue_free()
		if area.is_in_group('enemies') and hit_enemies.find(area) == -1:
			hit_enemies.append(area)
			has_hit.emit(area)
			if explosion:
				var _explosion = explosion_instance.instantiate()
				_explosion.global_position = area.global_position
				_explosion.get_node('particle').color = explosion_color
				_explosion.get_node('particle').initial_velocity_min = explosion_radius
				_explosion.get_node('particle').scale = Vector2(explosion_radius/100, explosion_radius/100)
				print(explosion_radius)
				_explosion.get_child(1).shape.radius = explosion_radius
				print(_explosion.get_child(1).shape.radius)
				_explosion.get_node('particle').emitting = true
				_explosion.has_hit.connect(origin._on_hit)
				_explosion.hit_enemies.append_array(hit_enemies)
				get_parent().add_child(_explosion)
			if !pierce:
				print('hit')
				queue_free()

func _on_has_hit(unit):
	has_hit.emit(unit)
