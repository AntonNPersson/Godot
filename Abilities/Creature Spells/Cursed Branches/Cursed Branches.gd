extends Node2D
var origin
var target
var tag = null

@export var cast_duration : float = 1.0
@export var cooldown : float = 5.0
@export var _range : float = 500
@export var tags : Array = ["Root"]
@export var values : Array = [5.0]
@export var cursed_branch_instance : PackedScene

@export var speed : float = 300
# Called when the node enters the scene tree for the first time.

func _use():
	origin.is_rooted = true
	await origin.get_tree().create_timer(cast_duration).timeout
	var cursed_branch = cursed_branch_instance.instantiate()
	if is_instance_valid(origin):
		cursed_branch.global_position = origin.global_position
		cursed_branch.speed = speed
		cursed_branch.origin = origin
		cursed_branch.target = target
		cursed_branch.tag = tags[0]
		cursed_branch.duration = values[0]
		cursed_branch._range = _range
		cursed_branch.cooldown = cooldown
		cursed_branch.cast_duration = cast_duration
		cursed_branch.add_to_group('projectiles')
		origin.get_tree().get_root().get_node('Main').add_child(cursed_branch)
		origin.is_rooted = false