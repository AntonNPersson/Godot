extends Node2D
var in_play = false

func _initialize():
	in_play = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_play:
		for a in get_tree().get_nodes_in_group('players'):
			if !a.in_combat:
				queue_free()
