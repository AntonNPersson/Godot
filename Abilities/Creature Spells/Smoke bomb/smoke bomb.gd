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
	get_child(0).visible = true
	get_child(0).play()
	for i in range(summons.size()):
		var duplicate = get_child(0).duplicate()
		summons[i].add_child(duplicate)
		duplicate.visible = true
		duplicate.play()
		duplicate.global_position = summons[i].global_position
		duplicate.scale = Vector2(0.2, 0.2)
		duplicate.animation_finished.connect(_on_finished)
		duplicates.append(duplicate)
		summons[i].get_node('Extra').get_child(0).emitting = true

func _on_finished():
	for i in range(duplicates.size()):
		duplicates[i].queue_free()

func _unuse():
	if not once:
		get_child(0).visible = false
		get_child(0).stop()
		origin.bonus_armor -= 10000
		once = true