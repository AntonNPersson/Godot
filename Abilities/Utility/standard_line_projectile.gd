extends Area2D
var origin
var target = Vector2.ZERO
var move = false
var _range
var speed
var direction
var caster
var start_pos
signal has_hit(unit, extra)
var hit_enemies = []
var angle_to_target
var pierce = false
var explosion_instance
var explosion_color
var explosion = false
var explosion_radius = 0
var hit_allies = false
var hit_allies_area = []
var multiple_hit = false
var multiple_hit_interval = 0
var multiple_hit_timer = 0
var split = false
var split_count = 0
var ricochet = false
var ricochet_count = 0
var extra = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if move:
		if self.global_position.distance_to(caster) >= _range:
			queue_free()
		
		if multiple_hit:
			multiple_hit_timer += delta
			if multiple_hit_timer >= multiple_hit_interval:
				multiple_hit_timer = 0
				hit_allies_area = []
				hit_enemies = []

		_check_collision()
		self.rotation = move_toward(rotation, angle_to_target, delta * 100)
		self.global_position += direction * speed * delta

func _start(vector, distance, velocity, unit, sprite_frames: SpriteFrames, collision_radius, light_size, light_color, sprite_scale, _pierce, _explosion, _explosion_radius, _origin, ally_hit = false, _multiple_hit = false, _multiple_hit_interval = 0, _ricochet = false, _ricochet_count = 0, _split = false, _split_count = 0):
	speed = velocity
	target = vector
	_range = distance
	caster = unit
	pierce = _pierce
	start_pos = unit
	origin = _origin
	hit_allies = ally_hit
	multiple_hit = _multiple_hit
	multiple_hit_interval = _multiple_hit_interval
	ricochet = _ricochet
	ricochet_count = _ricochet_count
	split = _split
	split_count = _split_count

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
	get_child(1).play()

func _find_closest_target_to_target(_target, group, another_group = null):
	var closest = null
	var distance = 1000000
	
	for area in get_tree().get_nodes_in_group(group):
		if _target.global_position.distance_to(area.global_position) < distance:
			if area == _target or hit_enemies.find(area) != -1 or hit_allies_area.find(area) != -1 or !is_instance_valid(area):
				continue
			distance = _target.global_position.distance_to(area.global_position)
			closest = area

	if another_group == null:
		return closest
	for area in get_tree().get_nodes_in_group(another_group):
		if _target.global_position.distance_to(area.global_position) < distance:
			if area == _target or hit_enemies.find(area) != -1 or hit_allies_area.find(area) != -1 or !is_instance_valid(area):
				continue
			distance = _target.global_position.distance_to(area.global_position)
			closest = area
	return closest


func _check_collision():
	var overlapping = self.get_overlapping_areas()
	
	for area in overlapping:
		if start_pos.distance_to(caster) > _range:
			queue_free()
		if area.is_in_group('enemies') and hit_enemies.find(area) == -1:
			if hit_allies:
				extra["Ally Hit"] = false
			hit_enemies.append(area)
			has_hit.emit(area, extra)
			if explosion:
				var _explosion = explosion_instance.instantiate()
				_explosion.global_position = area.global_position
				_explosion.get_node('particle').color = explosion_color
				_explosion.get_node('particle').initial_velocity_min = explosion_radius
				_explosion.get_node('particle').scale = Vector2(explosion_radius/100, explosion_radius/100)
				_explosion.get_child(1).shape.radius = explosion_radius
				_explosion.get_node('particle').emitting = true
				_explosion.has_hit.connect(_on_has_hit)
				_explosion.hit_enemies.append_array(hit_enemies)
				get_parent().add_child(_explosion)
			if ricochet and !pierce:
				if ricochet_count > 0:
					print(ricochet_count)
					var _projectile = self.duplicate()
					var new_target = _find_closest_target_to_target(area, "enemies")
					if !is_instance_valid(new_target) or new_target == null:
						queue_free()
						return
					_projectile._start(new_target.global_position, _range, speed, caster, get_child(1).sprite_frames, get_child(0).shape.radius, get_child(2).texture_scale, get_child(2).color, self.scale.x, pierce, explosion, explosion_radius, origin, hit_allies, multiple_hit, multiple_hit_interval, ricochet, ricochet_count - 1)
					get_parent().add_child(_projectile)
					_projectile.hit_enemies.append(area)
					_projectile.has_hit.connect(origin._on_hit)
			if split:
				var split_angle = deg_to_rad(10)
				for i in range(-1, split_count - 1):
					var _projectile = self.duplicate()
					var angle = split_angle * i
					var new_target = direction.rotated(angle) * _range + self.global_position
					var new_collision_radius = get_child(0).shape.radius * 0.2
					var new_scale = self.scale.x * 0.2
					_projectile._start(new_target, _range, speed, caster, get_child(1).sprite_frames, new_collision_radius, get_child(2).texture_scale, get_child(2).color, new_scale, pierce, explosion, explosion_radius, origin, hit_allies, multiple_hit, multiple_hit_interval, ricochet, ricochet_count)
					get_parent().add_child(_projectile)
					_projectile.hit_enemies.append(area)
					_projectile.has_hit.connect(origin._on_hit)
					_projectile.extra['Split'] = 0.2
			if !pierce:
				queue_free()
		if area.is_in_group("players") or area.is_in_group("player_summon"):
			if hit_allies:
				extra["Ally Hit"] = true
				if hit_allies_area.find(area) == -1:
					hit_allies_area.append(area)
					has_hit.emit(area, extra)

					if explosion:
						var _explosion = explosion_instance.instantiate()
						_explosion.global_position = area.global_position
						_explosion.get_node('particle').color = explosion_color
						_explosion.get_node('particle').initial_velocity_min = explosion_radius
						_explosion.get_node('particle').scale = Vector2(explosion_radius/100, explosion_radius/100)
						_explosion.get_child(1).shape.radius = explosion_radius
						_explosion.get_node('particle').emitting = true
						_explosion.has_hit.connect(_on_has_hit)
						_explosion.hit_allies_area.append_array(hit_allies_area)
						_explosion.hit_allies = true
						get_parent().add_child(_explosion)
					
					if ricochet and !pierce:
						if ricochet_count > 0:
							print(ricochet_count)
							var _projectile = self.duplicate()
							var new_target = _find_closest_target_to_target(area, "players", "player_summon")
							if !is_instance_valid(new_target) or new_target == null:
								queue_free()
								return
							_projectile._start(new_target.global_position, _range, speed, caster, get_child(1).sprite_frames, get_child(0).shape.radius, get_child(2).texture_scale, get_child(2).color, self.scale.x, pierce, explosion, explosion_radius, origin, hit_allies, multiple_hit, multiple_hit_interval, ricochet, ricochet_count - 1)
							get_parent().add_child(_projectile)
							_projectile.hit_allies_area.append(area)
							_projectile.has_hit.connect(origin._on_hit)

					if split:
						var split_angle = deg_to_rad(10)
						for i in range(-1, split_count - 1):
							var _projectile = self.duplicate()
							var angle = split_angle * i
							var new_target = direction.rotated(angle) * _range + self.global_position
							var new_collision_radius = get_child(0).shape.radius * 0.2
							var new_scale = self.scale.x * 0.2
							_projectile._start(new_target, _range, speed, caster, get_child(1).sprite_frames, new_collision_radius, get_child(2).texture_scale, get_child(2).color, new_scale, pierce, explosion, explosion_radius, origin, hit_allies, multiple_hit, multiple_hit_interval, ricochet, ricochet_count)
							get_parent().add_child(_projectile)
							_projectile.hit_allies_area.append(area)
							_projectile.has_hit.connect(origin._on_hit)
							_projectile.extra['Split'] = 0.2
					
					if !pierce:
						queue_free()

func _on_has_hit(unit):
	has_hit.emit(unit, extra)
