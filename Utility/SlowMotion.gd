extends Node
var _time_scale = 1

func _start_slow_motion(value, skip_cooldown = false, player = null):
	print("Slow motion started")
	value = max(value, 0.2)
	print("Time scale: " + str(value))
	_time_scale = value
	_apply_slow_motion()
	if skip_cooldown and player:
		player.get_node("InventoryManager").cooldown_timer_multiple = 1 / value

func _stop_slow_motion(player = null):
	_time_scale = 1
	_apply_slow_motion()
	if player:
		player.get_node("InventoryManager").cooldown_timer_multiple = 1

func _apply_slow_motion():
	Engine.time_scale = _time_scale
	Engine.physics_jitter_fix = _time_scale < 1