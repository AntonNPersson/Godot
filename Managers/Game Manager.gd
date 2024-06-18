extends Node
var is_singleplayer = false
var selected_character_name

var settings = {
	"screen_shake" : true,
	"moba_controls" : true,}

func _change_scene(parameter: String, mode : bool):
	get_tree().change_scene_to_file(parameter)	
	is_singleplayer = mode
	
func _pause_game():
	get_tree().get_nodes_in_group("players")[0].paused = true
	var bosses = get_tree().get_nodes_in_group('boss')
	for boss in bosses:
		boss.has_aggro = false
	var enemies = get_tree().get_nodes_in_group('enemies')
	for enemy in enemies:
		enemy.paused = true

func _continue_game():
	get_tree().get_nodes_in_group("players")[0].paused = false
	var bosses = get_tree().get_nodes_in_group('boss')
	for boss in bosses:
		boss.has_aggro = true
	var enemies = get_tree().get_nodes_in_group('enemies')
	for enemy in enemies:
		enemy.paused = false
