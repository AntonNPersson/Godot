extends Node2D
var origin
var target
var tag = null

@export var cast_duration : float = 0.1
@export var cooldown : float = 0.2
@export var _range : float = 30


# Called when the node enters the scene tree for the first time.
func _use():
	origin.do_action.emit(5, target, origin, "Damage")
