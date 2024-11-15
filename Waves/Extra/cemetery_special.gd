extends Wave

func _get_special():
	var players = get_tree().get_nodes_in_group("players")
	Utility.get_node('Brightness')._set_fog_layer(10)
	for player in players:
		if !player.has_node("Darkness"):
			var timer = Utility.get_node('TimerCreator')._create_timer(2, false, player)
			timer.name = "Darkness"
			timer.timeout.connect(_on_timeout.bind(player))
			timer.start()
			player.add_child(timer)

func _on_timeout(player):
	player.get_node('Control').on_action.emit(player.total_health * 0.05, player, player, 'PVEDarkness')
