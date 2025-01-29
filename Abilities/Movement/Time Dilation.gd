extends Node
var unit
@export var tooltip = "Dash forward, becoming invincible for a short time. Costs 35 stamina, and has zero cooldown."
@export var time_speed = 0.2
@export var cost = 5
@export var total_stamina_cost = 0.05
@export var icon : Texture
var is_dilated = false
var drain_timer = 0

func _use_ability(_delta):
	drain_timer += _delta * (1/time_speed)
	if is_dilated:
		if drain_timer >= 1:
			drain_timer = 0
			unit.current_stamina -= cost + (unit.total_stamina * total_stamina_cost)

	if unit.current_stamina <= 0:
		_stop_ability()

	if Input.is_action_just_pressed('Dash'):
		if unit.current_stamina - cost + (unit.total_stamina * total_stamina_cost) < 0:
			Utility.get_node("ErrorMessage")._create_error_message("Not enough stamina!", unit)
			return
		if !is_dilated:
			start_dash()
		else:
			_stop_ability()

func start_dash():
	unit.current_stamina -= cost + (unit.total_stamina * total_stamina_cost)
	Utility.get_node("SlowMotion")._start_slow_motion(time_speed, true, unit)
	is_dilated = true

func _stop_ability():
	Utility.get_node("SlowMotion")._stop_slow_motion(unit)
	is_dilated = false
