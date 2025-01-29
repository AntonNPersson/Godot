extends Node
var unit
@export var tooltip = "Dash forward, becoming invincible for a short time. Costs 35 stamina, and has zero cooldown."
@export var evade_increase = 1000
@export var sprint_speed = 40
@export var cost = 50
@export var duration = 3
@export var icon : Texture
var current_cooldown = 0
var is_blurred = false

func _use_ability(_delta):
	current_cooldown -= _delta
	if current_cooldown <= 0:
		is_blurred = false

	if is_blurred:
		Utility.get_node("AfterImages")._create_after_image(unit, 2)
		
	if Input.is_action_just_pressed('Dash'):
		if unit.current_stamina - cost < 0:
			Utility.get_node("ErrorMessage")._create_error_message("Not enough stamina!", unit)
			return
			
		if current_cooldown >= 0:
			Utility.get_node("ErrorMessage")._create_error_message("Blur on cooldown!", unit)
			return

		start_dash()
			


func start_dash():
	var extra = {'ability': "Blur",
				"Duration" : duration}
	unit.get_node("Control").on_action.emit(evade_increase, unit, unit, "FlatEvadeBuff", extra)
	unit.get_node("Control").on_action.emit(sprint_speed, unit, duration, "PercentSpeedBuff", extra)
	unit.current_stamina -= cost
	is_blurred = true
	current_cooldown = duration

