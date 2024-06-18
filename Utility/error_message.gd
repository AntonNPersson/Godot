extends Node
@export var error_message : Node

func _create_error_message(message, target):
	var save_path = target.get_tree().current_scene.get_child(0).get_node('UI')
	if save_path.has_node('ErrorMessage'):
		return
	var instance = error_message.duplicate()
	instance.get_child(0).get_child(0).text = '[center][color=RED]' + message + '[/color][/center]'
	target.get_tree().current_scene.get_child(0).get_node('UI').add_child(instance)
	await get_tree().create_timer(1).timeout
	if is_instance_valid(target):
		target.get_tree().current_scene.get_child(0).get_node('UI').get_node('ErrorMessage').queue_free()
