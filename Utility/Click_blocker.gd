extends Control

func _unhandled_input (event : InputEvent):
	if event is InputEventMouseButton and event.pressed:
		event.set_as_handled()