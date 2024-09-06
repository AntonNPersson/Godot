extends Area2D
var player

func _ready():
	player = get_tree().get_nodes_in_group("players")

func _get_special():
	for p in player:
		if p.global_position.distance_to(global_position) < 100:
			p.get_node('Control').on_action.emit(0.1, p, self, 'PVELight')
		else:
			p.get_node('Control').on_action.emit(0.1, p, self, 'PVELightRemove')
