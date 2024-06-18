extends Node
var target
var timer
@export var cast_duration = 0.0
@export var duration = 10.0
@export var bonus_speed = 1000.0
@export var tag = 'SpeedBuff'
@export var cooldown = 5.0
@export var _range = 1000000.0

func _use():
	if is_queued_for_deletion():
		pass
	
	timer = Timer.new()
	timer.timeout.connect(_on_timeout)
	timer.set_wait_time(duration)
	add_child(timer)
	timer.start()
	if is_instance_valid(target):
		target.do_action.emit(bonus_speed, target, duration, tag)
	
func _on_timeout():
	if target and is_instance_valid(target):
		queue_free()
