extends Node
var unit
@export var tooltip = "Dash forward, becoming invincible for a short time. Costs 35 stamina, and has zero cooldown."
@export var dash_speed = 500
@export var cost = 35
@export var particle_effects : CPUParticles2D
@export var icon : Texture
@export var cooldown = 6
@export var tags : Array[String]
@export var values : Array[float]
@export var _range : float
signal do_action()
var dash_vector = Vector2.ZERO
var is_dashing = false
var original_speed = 0
var dash_direction = Vector2.ZERO
var cooldown_timer = 0
var original_position = Vector2.ZERO
var target_position = Vector2.ZERO

var leap_time = 0.5
var leap_progress = 0.0

func _ready():
	original_speed = unit.total_speed

func _use_ability(delta):
	if Input.is_action_just_pressed('Dash'):
		if !is_dashing and unit.current_stamina - cost >= 0:
			start_dash()
			cooldown_timer = cooldown

	if is_dashing:
		update_dash(delta)

func start_dash():
	get_child(0).visible = true
	get_child(0).modulate = Color.RED
	get_child(0).scale = Vector2(1.4,1.4)
	get_child(0).z_index = 0
	get_child(0).global_position = unit.global_position
	get_child(0).play()
	is_dashing = true
	unit.current_stamina -= cost
	values[0] = 15 * unit.player_level
	values[1] = unit.total_health * 0.05
	original_position = unit.global_position
	original_speed = unit.total_speed
	target_position = unit.get_global_mouse_position()
	dash_direction = (target_position - unit.global_position).normalized()

func update_dash(delta):
	unit.total_speed = 0
	leap_progress += delta/leap_time

	if leap_progress >= 1:
		leap_progress = 1

	var t = leap_progress
	var height_offset = -4 * _range * t * (t - 1)

	var horizontal_movement = dash_direction * dash_speed * delta
	# Movement logic
	unit.global_position += horizontal_movement
	unit.global_position.y += height_offset * delta

	# Handle collisions
	var areas = unit.get_overlapping_areas()
	for a in areas:
		if a.is_in_group('obstacles'):
			end_dash()
			is_dashing = false
			break

	# End dash when timer runs out
	if unit.global_position.distance_to(target_position) < 5 or unit.global_position.distance_to(original_position) > _range:
		end_dash()
		is_dashing = false

func end_dash():
	get_child(0).visible = true
	get_child(0).scale = Vector2(3,3)
	get_child(0).global_position = unit.global_position + Vector2(0, 32)
	get_child(0).stop()
	get_child(0).play()
	unit.total_speed = original_speed
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if unit.global_position.distance_to(enemy.global_position) < 75:
				enemy.do_action.emit(values[0], enemy, unit, tags[0])
				enemy.do_action.emit(values[1], unit, unit, tags[1])

