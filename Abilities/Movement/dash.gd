extends Node
var unit
@export var tooltip = "Dash forward, becoming invincible for a short time. Costs 35 stamina, and has zero cooldown."
@export var dash_speed = 200
@export var cost = 35
@export var dash_duration = 0.2
@export var particle_effects : CPUParticles2D
@export var icon : Texture
signal do_action()
var dash_vector = Vector2.ZERO
var is_dashing = false
var original_speed = 0
var dash_direction = Vector2.ZERO
var dash_timer = 0

func _ready():
	original_speed = unit.total_speed

func _use_ability(delta):
	if Input.is_action_just_pressed('Dash'):
		if !is_dashing and unit.current_stamina - cost >= 0:
			start_dash()
			dash_speed = 300
			cost = 1

	if is_dashing:
		update_dash(delta)
	else:
		end_dash()

func start_dash():
	get_child(0).visible = true
	get_child(0).play()
	dash_duration = 0.3
	dash_timer = dash_duration  # To track progress separately
	is_dashing = true
	unit.current_stamina -= cost
	get_child(0).global_position = unit.global_position
	unit.get_node('Control').on_action.emit(dash_duration, unit, unit, 'SelfInvincible')
	dash_direction = unit.get_node('Control').movement_target.normalized()
	original_speed = unit.total_speed

func update_dash(delta):
	unit.total_speed = 0
	dash_timer -= delta

	# Movement logic
	unit.global_position += dash_direction * dash_speed * delta

	# Handle collisions
	var areas = unit.get_overlapping_areas()
	for a in areas:
		if a.is_in_group('obstacles'):
			dash_timer = 0
			break

	# End dash when timer runs out
	if dash_timer <= 0:
		is_dashing = false

func end_dash():
	get_child(0).visible = false
	unit.total_speed = original_speed
