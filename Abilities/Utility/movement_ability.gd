extends Area2D
var origin
var target = Vector2.ZERO
signal has_hit(unit)
var move = false
var _range
var speed
var direction
var type
var start_position = Vector2.ZERO

var pool
var pool_effect
var explosion
var explosion_radius
var explosion_effect
var light_color
var _ability
var sprint_timer = 0.2
var custom_move = false
var custom_end = false
var sprite_frames = null
var sprite_scale = 1

var max_distance

var hit_enemies = []
# Called when the node enters the scene tree for the first time.
func _start(origin, target, rnge, speed, type, light_color, explosion, explosion_radius, _ability, pool = false, sprite_frames = null, sprite_scale = 1, custom_movement = false, custom_end = false, custom_start = false):
	if target == null:
		queue_free()
		return
	start_position = origin.global_position
	self.origin = origin
	self.target = target
	self._range = rnge
	self.speed = speed
	self.type = type
	self.custom_move = custom_movement
	self.custom_end = custom_end
	self.sprite_frames = sprite_frames
	self.sprite_scale = sprite_scale
	if type == "Charge":
		self.direction = (target.global_position - origin.global_position).normalized()
		self.max_distance = origin.global_position.distance_to(target.global_position)
	if type == "Sprint":
		self.direction = (target - origin.global_position).normalized()
	self.global_position = origin.global_position
	self.explosion = explosion
	self.explosion_radius = explosion_radius
	self.light_color = light_color
	self._ability = _ability
	self.pool = pool
	explosion_effect = load("res://Abilities/Utility/explosion.tscn")
	pool_effect = load("res://Abilities/Utility/pool.tscn")
	self.move = true
	if type == "Charge" and !custom_movement:
		get_child(0).visible = true
		get_child(0).get_child(0).emitting = true
		get_child(0).get_child(0).color = light_color
	if type == "Blink" and !custom_movement:
		get_child(1).visible = true
		get_child(1).get_child(0).emitting = true
		get_child(1).get_child(0).color = light_color
	if type == "Sprint" and !custom_movement:
		get_child(0).visible = true
		get_child(0).get_child(0).emitting = true
		get_child(0).get_child(0).color = light_color
	if custom_movement and custom_start:
		if sprite_frames != null:
			var animated_sprite = AnimatedSprite2D.new()
			add_child(animated_sprite)
			animated_sprite.name = _ability.name
			animated_sprite.global_position = global_position
			animated_sprite.sprite_frames = sprite_frames
			animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
			animated_sprite.modulate = light_color
			animated_sprite.animation_finished.connect(_remove_sprite)
			animated_sprite.play()

func _remove_sprite():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_instance_valid(origin):
		return
	if type == "Charge":
		if move and is_instance_valid(target):
			direction = (target.global_position - origin.global_position).normalized()
			origin.global_position += direction * speed * delta
			if origin.global_position.distance_to(target.global_position) <= 30:
				origin.get_node('Control').movement_target = Vector2.ZERO
				origin.get_node('Control').attack_target = target
				hit_enemies.append(target)
				has_hit.emit(target)
				origin.get_node("Control").attack_sprite.get_child(0).play('default')
				origin.get_node("Control").attack_sprite.global_position = origin.global_position + (target.global_position - origin.global_position).normalized() * 20
				origin.get_node("Control").attack_sprite.rotation = (target.global_position - origin.global_position).angle()
				origin.get_node("Control").attack_sprite.modulate = light_color
				if explosion:
					var _explosion = explosion_effect.instantiate()
					_explosion.global_position = target.global_position
					_explosion.get_node('particle').color = light_color
					_explosion.get_node('particle').scale = Vector2(explosion_radius/3, explosion_radius/3)
					_explosion.get_node('particle').initial_velocity_min *= explosion_radius
					_explosion.get_child(1).shape.radius = explosion_radius
					_explosion.get_node('particle').emitting = true
					_explosion.has_hit.connect(_ability._on_hit)
					_explosion.hit_enemies.append_array(hit_enemies)
					get_tree().get_root().get_node('Main').add_child(_explosion)
				if !custom_move:
					queue_free()
				elif custom_move and custom_end:
					if sprite_frames != null:
						var animated_sprite = AnimatedSprite2D.new()
						add_child(animated_sprite)
						animated_sprite.name = _ability.name
						animated_sprite.global_position = global_position
						animated_sprite.sprite_frames = sprite_frames
						animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
						animated_sprite.modulate = light_color
						animated_sprite.animation_finished.connect(_remove_sprite)
						animated_sprite.play()
	if type == "Blink":
		if move and is_instance_valid(target):
			origin.global_position = target.global_position
			hit_enemies.append(target)
			has_hit.emit(target)
			if explosion:
					var _explosion = explosion_effect.instantiate()
					_explosion.global_position = target.global_position
					_explosion.get_node('particle').color = light_color
					_explosion.get_node('particle').scale = Vector2(explosion_radius/3, explosion_radius/3)
					_explosion.get_node('particle').initial_velocity_min *= explosion_radius
					_explosion.get_child(1).shape.radius = explosion_radius
					_explosion.get_node('particle').emitting = true
					_explosion.has_hit.connect(_ability._on_hit)
					_explosion.hit_enemies.append_array(hit_enemies)
					get_tree().get_root().get_node('Main').add_child(_explosion)
			explosion = false
			move = false
			if !custom_move:
				await get_tree().create_timer(0.5).timeout
				queue_free()
			elif custom_move and custom_end:
				if sprite_frames != null:
					var animated_sprite = AnimatedSprite2D.new()
					add_child(animated_sprite)
					animated_sprite.name = _ability.name
					animated_sprite.global_position = global_position
					animated_sprite.sprite_frames = sprite_frames
					animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
					animated_sprite.modulate = light_color
					animated_sprite.animation_finished.connect(_remove_sprite)
					animated_sprite.play()
	if type == "Sprint":
		if move:
			origin.global_position += direction * speed * delta
			sprint_timer += delta
			print(sprint_timer)
			if sprint_timer > 0.2 and !pool and explosion:
				var __explosion = explosion_effect.instantiate()
				__explosion.global_position = origin.global_position
				__explosion.get_node('particle').color = light_color
				__explosion.get_node('particle').initial_velocity_min = explosion_radius + randi() % 40 + 10
				__explosion.get_node('particle').emitting = true
				get_tree().get_root().get_node('Main').add_child(__explosion)
				sprint_timer = 0
			elif sprint_timer > 0.2 and pool and !explosion:
				var __explosion = pool_effect.instantiate()
				__explosion.global_position = origin.global_position
				__explosion.get_node('particle').color = light_color
				__explosion.get_node('particle').emitting = true
				__explosion.get_node('Sprite2D').modulate = light_color
				__explosion.has_hit.connect(_ability._on_hit)
				get_tree().get_root().get_node('Main').add_child(__explosion)
				sprint_timer = 0
			if origin.global_position.distance_to(start_position) < _range:
				origin.get_node('Control').movement_target = Vector2.ZERO
				origin.get_node('Control').update_sprite_direction((target - origin.global_position).normalized(), "Walk")
				if pool:
					return
				for enemy in origin.get_tree().get_nodes_in_group('enemies'):
					if origin.global_position.distance_to(enemy.global_position) < 40:
						if !hit_enemies.has(enemy):
							hit_enemies.append(enemy)
							has_hit.emit(enemy)
							var new_explosion = get_child(0).duplicate()
							new_explosion.global_position = enemy.global_position
							new_explosion.get_child(0).color = light_color
							new_explosion.get_child(0).initial_velocity_min = 10
							new_explosion.get_child(0).emitting = true
							new_explosion.visible = true
							get_tree().get_root().get_node('Main').add_child(new_explosion)

							if explosion:
								var _explosion = explosion_effect.instantiate()
								_explosion.global_position = enemy.global_position
								_explosion.get_node('particle').color = light_color
								_explosion.get_node('particle').initial_velocity_min = explosion_radius + randi() % 40 + 10
								_explosion.get_child(1).shape.radius = explosion_radius
								_explosion.get_node('particle').emitting = true
								_explosion.has_hit.connect(_ability._on_hit)
								_explosion.hit_enemies.append_array(hit_enemies)
								get_tree().get_root().get_node('Main').add_child(_explosion)
			else:
				origin.get_node('Control').movement_target = Vector2.ZERO
				move = false
				if !custom_move:
					queue_free()
				elif custom_move and custom_end:
					if sprite_frames != null:
						var animated_sprite = AnimatedSprite2D.new()
						add_child(animated_sprite)
						animated_sprite.name = _ability.name
						animated_sprite.global_position = global_position
						animated_sprite.sprite_frames = sprite_frames
						animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
						animated_sprite.modulate = light_color
						animated_sprite.animation_finished.connect(_remove_sprite)
						animated_sprite.play()

