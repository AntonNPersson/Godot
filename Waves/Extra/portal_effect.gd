extends Node2D
@export var interact_range = 30
@export var pop : Node
var interacting = false
signal enter_portal()

func _ready():
	get_node('AnimationPlayer').play('portal appearing')

func _initialize():
	pass

func _use(enable):
	enter_portal.emit()
	queue_free()

func _get_interacting():
	return interacting

func _on_animation_player_animation_finished(anim_name:StringName):
	if anim_name == "portal appearing":
		get_node('AnimationPlayer').play('portal rotating')

func remove_part(original: String, to_remove: String) -> String:
	var start_index = original.find(to_remove)
	if start_index == -1:
		return original  # Substring not found
	var end_index = start_index + to_remove.length()
	return original.substr(0, start_index) + original.substr(end_index, original.length() - end_index)
