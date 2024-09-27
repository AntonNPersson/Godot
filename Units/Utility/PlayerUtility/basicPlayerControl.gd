# FILEPATH: /C:/Users/Anton/Documents/Godot/Units/Utility/PlayerUtility/basicPlayerControl.gd

extends Sprite2D

# This script controls the basic movement and attack behavior of the player character.

@onready var stats = get_parent()
@onready var attack_bar = get_parent().get_node('UI').get_node('attackBar')
@onready var animation = get_parent().get_node('AnimatedSprite2D')
@onready var attack_sprite = get_parent().get_node('Meleebasicattack')
signal basic_attacking(target)

var colliding = false
var collision_direction = Vector2.ZERO
var movement_target = Vector2.ZERO
var mouse_pos = Vector2.ZERO
var rotation_speed = 200.0
var movement_threshold = 32.0
var basic_attack = false
var is_winding_upp = false
var is_dashing = false
var prohibit_attack = false

@export var original_material : ShaderMaterial = null
var saved_position = Vector2.ZERO

signal on_action(float, Node, Array, String)

var attack_timer = 0.3
var attack_target = null
var last_attack_target = null
var movement_skill = null
var current_sprite_direction = ""
var movement_penalty = 1.0 # 1.0 = normal speed, 0.4 = slow speed

var mouse_pointer_pressed = load('res://Sprites/Icons/pointer_pressed.png')
var mouse_pointer = load('res://Sprites/Icons/pointer.png')

#--------------------------#
# Helper functions
#--------------------------#

func _calculate_attack_percentage():
	# Calculates the current attack percentage based on the attack timer and total windup time.
	var perc = (attack_timer / stats.total_windup_time) * 100
	if perc <= 35:
		attack_bar.modulate = Color.GREEN
	else:
		attack_bar.modulate = Color.GRAY
	return (attack_timer / stats.total_windup_time) * 100

func update_sprite_direction(target_position, type):
	# Updates the sprite direction based on the target position and type of action.
	var direction_vector = target_position
	
	if type == "Attack":
		animation.set_speed_scale((2/stats.total_windup_time))
	else:
		animation.speed_scale = 1
	
	# Determine the cardinal direction based on the direction vector.
	if abs(direction_vector.x) > abs(direction_vector.y):
		if direction_vector.x > 0:
			current_sprite_direction = type + " East"
			animation.play(current_sprite_direction)
		else:
			current_sprite_direction = type + " West"
			animation.play(current_sprite_direction)
	else:
		if direction_vector.y > 0:
			current_sprite_direction = type + " South"
			animation.play(current_sprite_direction)
		else:
			current_sprite_direction = type + " North"
			animation.play(current_sprite_direction)

func _get_closest_visible_enemy_to_mouse():
	# Finds the closest visible enemy to the mouse position.
	var closest_node = null
	var closest_distance = 99999999
	
	if get_tree().get_nodes_in_group('enemies'):
		for child in get_tree().get_nodes_in_group('enemies'):
			var distance = mouse_pos.distance_to(child.global_position)
		
			if distance < closest_distance:
				closest_distance = distance
				closest_node = child

	return closest_node

#--------------------------#
# Main functions
#--------------------------#		

func _physics_process(delta):
	if stats.paused:
		return
	# Called every physics frame.
	_check_collision()
	if stats.movement_skill:
		stats.movement_skill._use_ability(delta)
	
	if GameManager.settings['moba_controls']:
		if basic_attack:
			if stats.is_stunned:
				return
			attack_bar.visible = true
			attack_bar.value = _calculate_attack_percentage()
			_attack_movement(delta, attack_target)
		else:
			if stats.is_rooted or stats.is_stunned:
				return
			movement_threshold = 20
			attack_bar.visible = false
			attack_timer = stats.total_windup_time
			_normal_movement(delta, movement_target)

	elif GameManager.settings['roguelike_controls']:
		if stats.is_stunned:
			return
		_wasd_attack_movement(delta, attack_target)
		movement_threshold = 32
		if stats.is_rooted:
			return
		_wasd_movement(delta)

func _on_action(value, target, user, tag, extra = null):
	# Called when an action is triggered.
	on_action.emit(value, target, user, tag, extra)
	_shake_camera()

func _shake_camera():
	if GameManager.settings['screen_shake']:
		stats.get_node('Camera').shake_intensity = 2.5
		stats.get_node('Camera').shake_duration = 0.25
		stats.get_node('Camera').is_shaking = true

func _attack_movement(delta, closest_target):
	# Handles the movement and attack behavior when there is a closest target.
	if closest_target != null:
		if closest_target.global_position.distance_to(stats.global_position) >= 600:
			attack_target = null
			return

		var distance_to_target = stats.global_position.distance_to(closest_target.global_position)
		var target_direction = (closest_target.global_position - stats.global_position).normalized()
		
		if distance_to_target > stats.total_range:
			stats._update_stats()
			stats.global_position += ((closest_target.global_position - stats.global_position).normalized() * stats.total_speed * delta)
			update_sprite_direction(target_direction, 'Walk')
			is_winding_upp = false
		else:
			update_sprite_direction(target_direction, "Attack")
			is_winding_upp = true
			
		if is_winding_upp:
			attack_timer -= delta
			if attack_timer <= 0.0:	
				for i in range(stats._apply_quick_attack_chance()):
					_attack([], [])
					await get_tree().create_timer(0.1).timeout
	else:
		animation.play(current_sprite_direction, 0)

func _wasd_attack_movement(delta, closest_target):
	if closest_target != null and !stats.lose_camera_focus and !prohibit_attack:
		if Input.is_action_pressed('Attack') and !Input.is_action_just_released('Attack'):
			attack_bar.visible = true
			attack_bar.value = _calculate_attack_percentage()
			attack_bar.fill_mode = 0
			is_winding_upp = true
			attack_timer -= delta
			mouse_pos = get_global_mouse_position()
			last_attack_target = attack_target
			attack_target = _get_closest_visible_enemy_to_mouse()
			if stats.global_position.distance_to(attack_target.global_position) < stats.total_range + 15:
				attack_target.is_hovered = true
				if last_attack_target != null and last_attack_target != attack_target:
					last_attack_target.is_hovered = false
			closest_target = attack_target
			if attack_target == null:
				return
			var distance_to_target = stats.global_position.distance_to(closest_target.global_position)
			if attack_timer <= 0.0:
				attack_target = _get_closest_visible_enemy_to_mouse()
				if distance_to_target <= stats.total_range + 15:
					for i in range(stats._apply_quick_attack_chance()):
						_attack([], [], delta)
						await get_tree().create_timer(0.1).timeout
				else:
					is_winding_upp = false
					attack_timer = stats.total_windup_time
					attack_bar.visible = false
		elif Input.is_action_just_released('Attack'):
			attack_target.is_hovered = false
			is_winding_upp = false
			attack_timer = stats.total_windup_time
			attack_bar.visible = false


func _attack(tags = null, values = null, delta = 0.0):
	stats.in_stealth = false
	if tags == null:
		tags = []
	if values == null:
		values = []
	attack_timer = stats.total_windup_time
	is_winding_upp = false
	if attack_target == null:
		attack_target = _get_closest_visible_enemy_to_mouse()
		if attack_target == null:
			return
		if stats.global_position.distance_to(attack_target.global_position) > stats.total_range:
			attack_target = null
			return
	basic_attacking.emit(attack_target)
	tags.append_array(stats.current_attack_modifier_tags)
	values.append_array(stats.current_attack_modifier_values)
	if !stats.melee:
		var instance = stats.basic_attack_scene.instantiate()
		get_tree().get_root().add_child(instance)
		instance.global_position = stats.global_position
		instance.do_damage.connect(_on_action)
		instance.tags = tags
		instance.values = values
		instance.unit = attack_target
		var crit = stats._apply_critical_damage(stats.total_attack_damage)
		instance.damage = crit["value"]
		if crit["critical"]:
			instance.is_critical = true
	else:
		update_sprite_direction(attack_target.global_position - stats.global_position, "Attack")
		attack_sprite.get_child(0).play('default')
		attack_sprite.global_position = stats.global_position + (attack_target.global_position - stats.global_position).normalized() * 20
		attack_sprite.rotation = (attack_target.global_position - stats.global_position).angle()
		attack_sprite.modulate = Color(1, 1, 1, 1)
		#remove_child(attack_sprite)
		#get_tree().get_root().add_child(attack_sprite)
		var crit = stats._apply_critical_damage(stats.total_attack_damage)
		var new_damage = crit["value"]
		if stats.total_attack_targets <= 1:
			attack_sprite.scale = Vector2(0.08, 0.08)
			var extra = {"basic_attacking": true, "critical": crit["critical"]}
			_on_action(new_damage, attack_target, stats, "Damage", extra)
			for i in range(tags.size()):
				_on_action(values[i], attack_target, stats, tags[i])
		else:
			attack_sprite.scale = Vector2(0.08 + (0.02*stats.total_attack_targets), 0.08 + (0.02*stats.total_attack_targets))
			var targets = get_tree().get_nodes_in_group('enemies')
			var g = 0
			for target in targets:
				if target.global_position.distance_to(attack_target.global_position) > 64:
					continue
				g += 1
				if g <= stats.total_attack_targets:
					var extra = {"basic_attacking": true, "critical": crit["critical"]}
					_on_action(new_damage, target, stats, "Damage", extra)
					for i in range(tags.size()):
						_on_action(values[i], target, stats, tags[i])

func _normal_movement(delta, current_target):
	# Handles the normal movement behavior.
	if current_target == Vector2.ZERO:
		return
		
	if attack_target != null:
		stats.target_marker._initialize(stats, false)

	var distance_to_target = stats.global_position.distance_to(mouse_pos)
	
	
	if distance_to_target <= movement_threshold:
		current_target = Vector2.ZERO
		animation.play(current_sprite_direction, 0)
	else:
		if !colliding:
			stats._update_stats()
			stats.global_position += (current_target * stats.total_speed) * delta
			update_sprite_direction(current_target, 'Walk')
		else:
			current_target = Vector2.ZERO
			stats.global_position -= collision_direction * stats.total_speed * delta
			colliding = false

func _wasd_movement(delta):
	# Handles the movement behavior using the WASD keys.
	var movement = Vector2.ZERO
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("Move_Up"):
		movement.y -= 1
		direction.y = -1
	elif Input.is_action_pressed("Move_Down"):
		movement.y += 1
		direction.y = 1
	
	if Input.is_action_pressed("Move_Left"):
		movement.x -= 1
		direction.x = -1
	elif Input.is_action_pressed("Move_Right"):
		movement.x += 1
		direction.x = 1
	
	if !colliding:
		if movement != Vector2.ZERO:
			movement_target = movement.normalized()
			stats._update_stats()
			stats.global_position += ((movement_target * stats.total_speed) * delta) * movement_penalty
			update_sprite_direction(direction, 'Walk')
		else:
			animation.play(current_sprite_direction, 0)
	else:
		stats.global_position -= collision_direction * stats.total_speed * delta
		colliding = false

#--------------------------#
# Input and extra functions
#--------------------------#

func _input(event):
	# Handles input events.
	if GameManager.settings['moba_controls']:
		if event.is_action_pressed("Move") and !stats.lose_camera_focus:
			Input.set_custom_mouse_cursor(mouse_pointer_pressed)
			if attack_timer >= 0.0 and attack_timer <= (stats.total_windup_time * 0.35) and basic_attack:
				for i in range(stats._apply_quick_attack_chance()):
					_attack([], [])
					await get_tree().create_timer(0.1).timeout
			basic_attack = false
			attack_timer = stats.total_windup_time
			mouse_pos = get_global_mouse_position()
			movement_target = (mouse_pos - stats.global_position).normalized()
			
		if event.is_action_pressed('AttackIntention'):
			mouse_pos = get_global_mouse_position()
			attack_target = _get_closest_visible_enemy_to_mouse()
			if attack_target == null:
				return
			var sprite = attack_target.get_node('AnimatedSprite2D')
			original_material = sprite.material
			var new_material = original_material.duplicate()
			new_material.set_shader_parameter("hit_effect_color", Color.GREEN)
			new_material.set_shader_parameter("hit_effect_intensity", 0.6)
			sprite.material = new_material
			await get_tree().create_timer(0.15).timeout
			if is_instance_valid(sprite):
				sprite.material = original_material
				basic_attack = true

		if event.is_action_released("Move"):
			Input.set_custom_mouse_cursor(mouse_pointer)
		
		#Game manager controls
		if event.is_action_pressed("test_menu"):
			print_debug("Game manager controls, turn off before release")	
			GameManager.load_menu()
	elif GameManager.settings['roguelike_controls']:
		if event.is_action_pressed("Attack") and !stats.lose_camera_focus:
			Input.set_custom_mouse_cursor(mouse_pointer_pressed)
			mouse_pos = get_global_mouse_position()
			attack_target = _get_closest_visible_enemy_to_mouse()
			if attack_target == null:
				return
			if stats.melee:
				movement_penalty = 0.6
			else:
				movement_penalty = 0.5
		if event.is_action_released("Attack"):
			Input.set_custom_mouse_cursor(mouse_pointer)
			movement_penalty = 1.0
			if attack_target == null:
				return
			attack_target.is_hovered = false
			var distance_to_target = stats.global_position.distance_to(attack_target.global_position)
			if attack_timer >= 0.0 and attack_timer <= (stats.total_windup_time * 0.35) and distance_to_target <= stats.total_range + 15:
				for i in range(stats._apply_quick_attack_chance()):
					_attack([], [])
					await get_tree().create_timer(0.1).timeout
			attack_timer = stats.total_windup_time
			attack_bar.visible = false
			attack_target = null

func _trigger_target_marker(target, on):
	# Triggers the target marker effect on the given target.
	if target.dead:
		return
	var sprite = target.get_node('Sprite2D')
	var original_material = sprite.material
	var new_material = original_material.duplicate()
	
	if on:
		new_material.set_shader_parameter("outline_intensity", 0.6)
	else:
		new_material.set_shader_parameter("outline_intensity", 0.0)
	
	sprite.material = new_material
	await get_tree().create_timer(0.2).timeout
	sprite.material = original_material		

func _check_collision():
	# Checks for collisions with obstacles.
	var overlapping = stats.get_overlapping_areas()
	
	for area in overlapping:
		if area.is_in_group('obstacles'):
			var collision_point = area.get_node("CollisionShape2D").global_position
			collision_direction = (collision_point - stats.global_position).normalized()
			colliding = true
