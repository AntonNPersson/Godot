extends Node
var target
var timer
var origin
@export var cast_duration = 0.1
@export var duration = 99999
@export var stacks = 1
@export var tag = 'Poison'
@export var cooldown = 99999
@export var _range = 10000000
var always_active = true

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
	if origin and is_instance_valid(origin):
		origin.attack_modifier_tags.erase(tag)
		origin.attack_modifier_values.erase(stacks)
		queue_free()
