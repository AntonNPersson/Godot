extends Node
var unit
@export var tooltip = ""
@export var sprint_speed = 40
@export var cost = 50
@export var sprint_duration = 3
@export var rage_regenerated = 10
@export var icon : Texture
var current_cooldown = 0

func _use_ability(_delta):
	current_cooldown -= _delta
	if get_child(0).is_playing():
		get_child(0).global_position = unit.global_position
	if Input.is_action_just_pressed('Dash'):
		if unit.current_stamina - cost < 0:
			Utility.get_node("ErrorMessage")._create_error_message("Not enough stamina!", unit)
			return
			
		if current_cooldown >= 0:
			Utility.get_node("ErrorMessage")._create_error_message("Induced Rage on cooldown!", unit)
			return

		start_dash()
			


func start_dash():
	get_child(0).play()
	unit.get_node("Control").on_action.emit(sprint_speed, unit, sprint_duration, "PercentSpeedBuff")
	unit.get_node("Control").on_action.emit(rage_regenerated, unit, unit, "RageRegenBuff", {'Duration': sprint_duration})
	unit.current_stamina -= cost
	current_cooldown = sprint_duration

