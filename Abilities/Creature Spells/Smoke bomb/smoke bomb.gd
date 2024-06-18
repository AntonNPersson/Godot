extends Node2D
var target : Node
var origin : Node
var target_position : Vector2
var tag = null
var cooldown = 1000000
var once = false

@export var cast_duration : float

func _use():
	global_position = origin.global_position
	origin.bonus_armor += 10000
	get_child(0).emitting = true

func _unuse():
	if not once:
		origin.bonus_armor -= 10000
		get_child(0).emitting = false
		once = true