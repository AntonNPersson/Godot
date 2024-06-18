extends Task

# Keep running the child until it gives a result

class_name RepeatChild

func _run(_delta):
	get_child(0)._run(_delta)
	_running()
