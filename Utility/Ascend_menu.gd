extends Panel
var player
var rm

func _on_ascend_pressed():
	var player = get_tree().get_nodes_in_group("players")[0]
	player.power += 0.2
	player.ascension_level += 1
	player._reset_completed_waves()
	get_tree().get_root().get_node('Main').get_child(0).get_node('RoundManager')._next_area('Town', 0)



func _on_return_pressed():
	GameManager._change_scene('res://Scenes/Menu.tscn', true)
