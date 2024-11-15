extends Area2D
var player

func _ready():
	player = get_tree().get_nodes_in_group("players")

func _get_special():
	for p in player:
		if !p.has_meta('Darkness'):
			return

		if p.global_position.distance_to(global_position) < 150:
			p.get_node('Control').on_action.emit(0.1, p, self, 'PVELight')
			p.set_meta('Light', self)
		elif p.has_meta('Light') and p.get_meta('Light') == self:
			p.get_node('Control').on_action.emit(0.1, p, self, 'PVELightRemove')
			p.set_meta('Light', null)
