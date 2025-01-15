extends Node
var unit
@export var tooltip = "Dash forward, becoming invincible for a short time. Costs 35 stamina, and has zero cooldown."
@export var sprint_speed = 40
@export var cost = 50
@export var sprint_duration = 3
@export var particle_effects : CPUParticles2D
@export var icon : Texture
var current_cooldown = 0

func _use_ability(_delta):
	current_cooldown -= _delta
	if Input.is_action_just_pressed('Dash'):
		if unit.current_stamina - cost < 0:
			Utility.get_node("ErrorMessage")._create_error_message("Not enough stamina!", unit)
			return
			
		if current_cooldown >= 0:
			Utility.get_node("ErrorMessage")._create_error_message("Sprint on cooldown!", unit)
			return

		start_dash()
			


func start_dash():
	unit.get_node("Control").on_action.emit(sprint_speed, unit, sprint_duration, "PercentSpeedBuff")
	unit.get_node("Control").on_action.emit(sprint_duration, unit, unit, "MovementPenaltyBuff")
	unit.current_stamina -= cost
	current_cooldown = sprint_duration

