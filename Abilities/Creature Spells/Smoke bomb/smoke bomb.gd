extends Node2D
var target : Node
var origin : Node
var target_position : Vector2
var tag = null
var cooldown = 1000000
var once = false

@export var cast_duration : float

func _use(summons : Array = []):
	global_position = origin.global_position
	origin.bonus_armor += 10000
	get_child(0).visible = true
	get_child(0).play()

func _unuse():
	if not once:
		get_child(0).visible = false
		get_child(0).stop()
		origin.bonus_armor -= 10000
		once = true
