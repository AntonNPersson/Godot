extends Area2D
var enemies
var boss
var player
var map

# Called when the node enters the scene tree for the first time.
func _ready():
	enemies = get_tree().get_nodes_in_group("enemies")
	boss = get_tree().get_nodes_in_group("boss")
	player = get_tree().get_nodes_in_group("players")
	map = get_tree().current_scene.get_node('CanvasModulate/WaveManager')

func _get_special():
	if player[0].global_position.distance_to(self.global_position) < 100:
		if map.boss_ready:
			map._start_boss()