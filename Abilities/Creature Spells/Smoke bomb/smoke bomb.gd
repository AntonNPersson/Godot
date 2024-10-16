extends Node2D
var target : Node
var origin : Node
var target_position : Vector2
var tag = null
var cooldown = 1000000
var once = false

var duplicates = []

@export var cast_duration : float

func _use(summons : Array = []):
	global_position = origin.global_position
	origin.bonus_armor += 10000
	get_child(0).emitting = true
	for i in range(summons.size()):
		var duplicate = get_child(0).duplicate()
		summons[i].add_child(duplicate)
		duplicate.emitting = true
		duplicate.global_position = summons[i].global_position
		duplicate.scale = Vector2(0.2, 0.2)
		duplicates.append(duplicate)
		summons[i].get_node('Extra').get_child(0).emitting = true
	await get_tree().create_timer(0.5).timeout
	for i in range(duplicates.size()):
		duplicates[i].queue_free()

func _unuse():
	if not once:
		origin.bonus_armor -= 10000
		get_child(0).emitting = false
		once = true