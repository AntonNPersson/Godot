extends Node
var unit
@export var tooltip = "Dash forward, becoming invincible for a short time. Costs 35 stamina, and has zero cooldown."
@export var armor_increase = 40
@export var speed_reduction = 40
@export var thorns_increase = 20
@export var cost = 50
@export var duration = 4
@export var icon : Texture
var current_cooldown = 0

func _use_ability(_delta):
	current_cooldown -= _delta
	get_child(0).global_position = unit.global_position

	if Input.is_action_just_pressed('Dash'):
		if unit.current_stamina - cost < 0:
			Utility.get_node("ErrorMessage")._create_error_message("Not enough stamina!", unit)
			return
			
		if current_cooldown >= 0:
			Utility.get_node("ErrorMessage")._create_error_message("Blur on cooldown!", unit)
			return

		start_dash()

func start_dash():
	get_child(0).visible = true
	get_child(0).play()
	var extra = {'ability': "Fortify",
				"Duration" : duration}
	unit.get_node("Control").on_action.emit(thorns_increase * unit.player_level, unit, unit, "FlatThornsBuff", extra)
	unit.get_node("Control").on_action.emit(-speed_reduction, unit, duration, "PercentSpeedBuff", extra)
	unit.get_node("Control").on_action.emit(armor_increase * unit.player_level, unit, duration, "FlatArmorBuff", extra)
	unit.current_stamina -= cost
	current_cooldown = duration

func _animation_finished():
	get_child(0).visible = false

