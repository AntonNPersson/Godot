extends CanvasModulate

func _ready():
	call_deferred('_initialize_managers')

func _initialize_managers():
	print('Game Initialized')
	if GameManager.is_save_file:
		get_node('CharacterManager').selected_character_name = load_specific_value(get_node('CharacterManager').get_path(), "selected_character_name")
	var player = get_node('CharacterManager')._initialize()
	get_node('WaveManager')._initialize()
	get_node('MapManager')._initialize()
	get_node('AbilityManager')._initialize()
	get_node('ItemManager')._initialize()
	if GameManager.is_save_file:
		load_game()
		get_node('AbilityManager')._load_abilities(player.im_abilities)
		player.get_node('InventoryManager').load_items()
	await get_tree().create_timer(0.5).timeout
	get_node('CharacterManager').start_round_manager.emit()


func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = get_node(node_data['filename'])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
	save_file.close()

func load_specific_value(filename_to_find: String, key_to_find: String) -> Variant:
	if not FileAccess.file_exists("user://savegame.save"):
		return null # Error! We don't have a save to load.

	# Load the file line by line and process the dictionary to find the specific filename
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Parse the JSON string
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Check if the current entry matches the desired filename
		if node_data.has("filename") and node_data["filename"] == filename_to_find:
			# Check if the key exists and return the value if found
			if node_data.has(key_to_find):
				save_file.close()
				return node_data[key_to_find]
			else:
				print("Key not found:", key_to_find)
				save_file.close()
				return null

	# If we reach here, the file or key wasn't found
	print("Filename not found:", filename_to_find)
	save_file.close()
	return null
