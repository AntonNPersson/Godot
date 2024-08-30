extends Node
var unit
@export var tooltip = "Dash forward, becoming invincible for a short time. Costs 35 stamina, and has zero cooldown."
@export var dash_speed = 500
@export var cost = 35
@export var dash_duration = 0.2
@export var particle_effects : CPUParticles2D
signal do_action()
var dash_vector = Vector2.ZERO
var is_dashing = false
var original_speed = 0
var dash_direction = Vector2.ZERO

func _ready():
	original_speed = unit.total_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _use_ability(delta):
	if Input.is_action_just_pressed('Dash'):
		get_child(0).restart()
		get_child(0).emitting = true
		if !is_dashing and unit.current_stamina - cost >= 0:
			particle_effects.global_position = unit.global_position
			dash_vector = Vector2(dash_speed, 0)
			dash_duration = 0.2
			is_dashing = true
			unit.current_stamina -= cost
			unit.get_node('Control').on_action.emit(dash_duration, unit, unit, 'SelfInvincible')
			dash_direction = unit.get_node('Control').movement_target
			original_speed = unit.total_speed
	
	if dash_duration > 0 and is_dashing:
		unit.total_speed = 0
		var areas = unit.get_overlapping_areas()
		for a in areas:
			if a.is_in_group('obstacles'):
				dash_duration = 0.2
				is_dashing = false
		unit.global_position += dash_direction * dash_speed * delta
		dash_duration -= delta
	else:
		dash_vector = Vector2.ZERO
		is_dashing = false
		unit.total_speed = original_speed
