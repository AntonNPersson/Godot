extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused:
			print("continuing")
			GameManager._continue_game()
		else:
			print("pausing")
			GameManager._pause_game()
