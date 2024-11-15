extends Node

func load():
	# Load the save file and set the values
	if not FileAccess.file_exists("user://ascension.save"):
		return # Error! We don't have a save to load.
	Utility.get_node('AscensionBalance')._set_balance(load_specific_value(get_path(), "ascension_currency"))
	Utility.get_node('AscensionStats')._set_bonus_ascension_gain(load_specific_value(get_path(), "bonus_ascension_gain"))
	Utility.get_node('AscensionStats')._set_bonus_xp_gain(load_specific_value(get_path(), "bonus_xp_gain"))
	Utility.get_node('AscensionStats')._set_bonus_drop_rate(load_specific_value(get_path(), "bonus_drop_rate"))

func load_specific_value(filename_to_find: String, key_to_find: String) -> Variant:
	if not FileAccess.file_exists("user://ascension.save"):
		return null # Error! We don't have a save to load.

	# Load the file line by line and process the dictionary to find the specific filename
	var save_file = FileAccess.open("user://ascension.save", FileAccess.READ)
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
	return 0

func save():
	var save_dict = {
		"filename" : get_path(),
		'ascension_currency': Utility.get_node('AscensionBalance').ascension_currency,
		'bonus_ascension_gain': Utility.get_node('AscensionStats').bonus_ascension_gain,
		'bonus_xp_gain': Utility.get_node('AscensionStats').bonus_xp_gain,
		'bonus_drop_rate': Utility.get_node('AscensionStats').bonus_drop_rate,
		'pre_chosen_abilities': Utility.get_node('AscensionStats').pre_chosen_abilities
	}
	return save_dict
