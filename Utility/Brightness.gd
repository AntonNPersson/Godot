extends Node
var canvas

# Called when the node enters the scene tree for the first time.

func _set_color(value):
	canvas = get_tree().current_scene.get_child(0)
	canvas.color = value

func _set_fog_layer(value):
	canvas = get_tree().current_scene.get_child(1)
	canvas.layer = value
