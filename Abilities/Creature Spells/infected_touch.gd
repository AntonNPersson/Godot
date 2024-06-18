extends Node
var target
var timer
var origin
@export var cast_duration = 0.1
@export var duration = 6.0
@export var stacks = 1
@export var tag = 'Infected'
@export var cooldown = 5.0
@export var _range = 10000000

func _use():
	if is_queued_for_deletion():
		pass
	
	timer = Timer.new()
	timer.timeout.connect(_on_timeout)
	timer.set_wait_time(duration)
	add_child(timer)
	timer.start()
	if origin and is_instance_valid(origin):
		origin.attack_modifier_tags.append(tag)
		origin.attack_modifier_values.append(stacks)
	
func _on_timeout():
	if target and is_instance_valid(target):
		target.attack_modifier_tags.remove(tag)
		target.attack_modifier_values.erase(tag)
		queue_free()
