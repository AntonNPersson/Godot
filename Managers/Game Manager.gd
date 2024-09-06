extends Node
var is_singleplayer = false
var is_save_file = false
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
		boss.paused = true
	var enemies = get_tree().get_nodes_in_group('enemies')
	for enemy in enemies:
		enemy.paused = true

func _continue_game():
	get_tree().get_nodes_in_group("players")[0].paused = false
	var bosses = get_tree().get_nodes_in_group('boss')
	for boss in bosses:
		boss.has_aggro = true
		boss.paused = false
	var enemies = get_tree().get_nodes_in_group('enemies')
	for enemy in enemies:
		enemy.paused = false

func save():
	var save_dict = {
		"settings" : settings,
		"selected_character_name" : selected_character_name,
		"is_singleplayer" : is_singleplayer,
	}
	return save_dict

func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func new_game():
	is_singleplayer = true
	is_save_file = false
	_change_scene("res://Scenes/Game.tscn", true)


func load_game():
	is_singleplayer = true
	is_save_file = true
	_change_scene("res://Scenes/Game.tscn", true)

	
