extends Node2D
@export var hitboxx : Node
var player = null

var ab = []

func _process(delta):
	if player == null:
		return

func _shake_camera(unit):
	if GameManager.settings['screen_shake']:
		unit.get_node('Camera').shake_intensity = 5
		unit.get_node('Camera').shake_duration = 0.2
		unit.get_node('Camera').is_shaking = true

func _check_collision(hitbox, _call : Callable, child = 0, enemy = false):
	if is_instance_valid(hitbox) == false:
		return
	var box = hitbox.get_child(child)
	var overlapping_areas = box.get_overlapping_areas()
	if !enemy:
		for area in overlapping_areas:
			if area.is_in_group('players') or area.is_in_group('player_summon'):
				_call.call(area)
	else:
		for area in overlapping_areas:
			if area.is_in_group('enemies'):
				_call.call(area)
	hitbox.queue_free()
	

func _create_circle_ability(size : float, duration : float, direction: Vector2, origini : Node, _call : Callable, after_effect : PackedScene = null, multipy : float = 1.0, enemy = false):
	for child in get_tree().get_nodes_in_group('players'):
		player = child
	origini.is_rooted = true
	for i in range(0, multipy):
		ab.append(i)
		var hitbox = hitboxx.duplicate()
		hitbox._initialize()
		hitbox.get_node('Circle').visible = true
		hitbox.scale = Vector2(size, size)
		hitbox.global_position += direction * 64 * size
		origini.add_child(hitbox)
		if enemy:
			hitbox.modulate = Color(0, 1, 0, 1)
		hitbox.get_node('Circle').get_node('AnimationPlayer').speed_scale = 1/duration
		hitbox.get_node('Circle').get_node('AnimationPlayer').play('Fade_in_circle')
		if i == 0:
			await get_tree().create_timer(duration).timeout
		if !is_instance_valid(origini) or origini.is_queued_for_deletion():
			return
		origini.is_rooted = false
		if after_effect:
			_shake_camera(player)
			var effect = after_effect.instantiate()
			hitbox.get_tree().get_root().add_child(effect)
			effect.global_position = hitbox.global_position
			effect.scale = Vector2(size, size)
		_check_collision(hitbox, _call, 0, enemy)

func _create_rectangle_ability(size : Vector2, duration : float, direction: Vector2, origini : Node, _call : Callable, after_effect : PackedScene = null, enemy = false):
	for child in get_tree().get_nodes_in_group('players'):
		player = child
	origini.is_rooted = true
	var hitbox = hitboxx.duplicate()
	hitbox._initialize()
	hitbox.get_node('Rectangle').visible = true
	hitbox.scale = size
	hitbox.global_position += direction * 78 * size.x
	hitbox.rotation = direction.angle()
	origini.add_child(hitbox)
	if enemy:
		hitbox.modulate = Color(0, 1, 0, 1)
	hitbox.get_node('Rectangle').get_node('AnimationPlayer').speed_scale = 1/duration
	hitbox.get_node('Rectangle').get_node('AnimationPlayer').play('Fade_in')
	await get_tree().create_timer(duration).timeout
	if !is_instance_valid(origini):
		return
	origini.is_rooted = false
	if after_effect:
		_shake_camera(player)
		var effect = after_effect.instantiate()
		hitbox.get_tree().get_root().add_child(effect)
		effect.global_position = hitbox.global_position
		effect.scale = size
	_check_collision(hitbox, _call, 0, enemy)

func _create_targeted_circle_ability(size : float, duration : float, target : Vector2, origini : Node, _call : Callable, after_effect : PackedScene = null, enemy = false):
	for child in get_tree().get_nodes_in_group('players'):
		player = child
	if origini != get_tree().get_nodes_in_group('players')[0]:
		origini.is_rooted = true
	var hitbox = hitboxx.duplicate()
	hitbox._initialize()
	hitbox.get_node('Circle').visible = true
	hitbox.scale = Vector2(size, size)
	hitbox.global_position = target
	if enemy:
		hitbox.modulate = Color(0, 1, 0, 1)
	origini.get_tree().get_root().add_child(hitbox)
	hitbox.get_node('Circle').get_node('AnimationPlayer').speed_scale = 1/duration
	hitbox.get_node('Circle').get_node('AnimationPlayer').play('Fade_in_circle')
	await get_tree().create_timer(duration).timeout
	if !is_instance_valid(origini) or !is_instance_valid(hitbox):
		return
	origini.is_rooted = false
	if after_effect:
		_shake_camera(player)
		var effect = after_effect.instantiate()
		hitbox.get_tree().get_root().add_child(effect)
		effect.global_position = hitbox.global_position
		effect.scale = Vector2(size, size)
	_check_collision(hitbox, _call, 0, enemy)

func _create_targeted_rectangle_ability(size : Vector2, duration : float, target : Node, origini : Node, _call : Callable, after_effect : PackedScene = null, enemy = false):
	for child in get_tree().get_nodes_in_group('players'):
		player = child
	origini.is_rooted = true
	var hitbox = hitboxx.duplicate()
	hitbox._initialize()
	hitbox.get_node('Rectangle').visible = true
	hitbox.scale = size
	hitbox.global_position = target.global_position
	hitbox.rotation = (target.global_position - origini.global_position).angle()
	if enemy:
		hitbox.modulate = Color(0, 1, 0, 1)
	origini.add_child(hitbox)
	hitbox.get_node('Rectangle').get_node('AnimationPlayer').speed_scale = 1/duration
	hitbox.get_node('Rectangle').get_node('AnimationPlayer').play('Fade_in')
	await get_tree().create_timer(duration).timeout
	if !is_instance_valid(origini):
		return
	origini.is_rooted = false
	if after_effect:
		_shake_camera(player)
		var effect = after_effect.instantiate()
		hitbox.get_tree().get_root().add_child(effect)
		effect.global_position = hitbox.global_position
		effect.scale = size
	_check_collision(hitbox, _call, 0, enemy)

func _create_flexible_rectangle_ability(size_y : float, size_x : float, duration : float, direction: Vector2, origini : Node, _call : Callable, after_effect : PackedScene = null, do_damage : bool = false, enemy = false):
	for child in get_tree().get_nodes_in_group('players'):
		player = child
	origini.is_rooted = true
	var hitbox = hitboxx.duplicate()
	hitbox._initialize()
	hitbox.get_node('Rectangle').visible = true
	var scale_factor_x = size_x/100
	var scale_factor_y = size_y/100
	hitbox.scale = Vector2(scale_factor_x, scale_factor_y)
	hitbox.global_position += direction * 78 * size_x
	hitbox.rotation = direction.angle()
	if enemy:
		hitbox.modulate = Color(0, 1, 0, 1)
	origini.add_child(hitbox)
	hitbox.get_node('Rectangle').get_node('AnimationPlayer').speed_scale = 1/duration
	hitbox.get_node('Rectangle').get_node('AnimationPlayer').play('Fade_in')
	await get_tree().create_timer(duration).timeout
	if !is_instance_valid(origini):
		return
	origini.is_rooted = false
	if after_effect:
		_shake_camera(player)
		var effect = after_effect.instantiate()
		hitbox.get_tree().get_root().add_child(effect)
		effect.global_position = hitbox.global_position
		effect.scale = Vector2(size_x, size_y)
	if do_damage:
		_check_collision(hitbox, _call, 0, enemy)

func _create_cone_ability(size : Vector2, duration : float, direction: Vector2, origini : Node, _call : Callable, after_effect : PackedScene = null, enemy = false):
		for child in get_tree().get_nodes_in_group('players'):
			player = child
		origini.is_rooted = true
		var hitbox = hitboxx.duplicate()
		hitbox._initialize()
		hitbox.get_node('Cone').visible = true
		hitbox.scale = size
		hitbox.global_position += direction * 78 * size.x
		hitbox.rotation = direction.angle()
		if enemy:
			hitbox.modulate = Color(0, 1, 0, 1)
		origini.add_child(hitbox)
		hitbox.get_node('Cone').get_node('AnimationPlayer').speed_scale = 1/duration
		hitbox.get_node('Cone').get_node('AnimationPlayer').play('Fade_in')
		await get_tree().create_timer(duration).timeout
		if !is_instance_valid(origini):
			return
		origini.is_rooted = false
		if after_effect:
			_shake_camera(player)
			var effect = after_effect.instantiate()
			origini.add_child(effect)
			effect.global_position = hitbox.global_position
			effect.scale = Vector2(size.x, size.y + 0.5)
			effect.rotation = hitbox.rotation + PI/2
		_check_collision(hitbox, _call, 2, enemy)

