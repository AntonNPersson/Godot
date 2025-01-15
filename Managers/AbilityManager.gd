extends Node
signal picked(ability_, subwave)
signal curse_picked(curse)
signal enchant_picked(enchant, ability_)
var popUp
var ability_popup
var curse_popup
var enchant_popup
var button

var int_scene
var dex_Scene
var str_Scene
var int_list
var dex_List
var str_List
var int_instance
var dex_Instance
var str_Instance

var current_ability_choices
var chosen_ability_choices = []
var selected_ability
var current_ability_round = 0
var reroll_amount = 99

var curse_scene
var curse_list
var curse_instance
var removed_curses = []
var chosen_curses = []
var loaded_curses = []

var enchant_scene
var enchant_list
var enchant_instance
var enchant_index
var enchant_mode = true # true = return to town, false = subwave
var reroll_mode = false # false = reroll enchanted ability, true = reroll same ability
var chosen_enchant_ability = null
var removed_enchants = []
var loaded_enchants = []
var chosen_enchants = []

var target
var is_subwave = false

var initialized = false
# Called when the node enters the scene tree for the first time.
func _initialize():
	int_scene = preload("res://Abilities/int.tscn")
	dex_Scene = preload("res://Abilities/dex.tscn")
	str_Scene =  preload("res://Abilities/str.tscn")
	curse_scene = preload("res://Abilities/Ascension Debuffs.tscn")
	enchant_scene = preload("res://Abilities/Enchant List.tscn")
	int_instance = int_scene.instantiate()
	dex_Instance = dex_Scene.instantiate()
	str_Instance = str_Scene.instantiate()
	curse_instance = curse_scene.instantiate()
	enchant_instance = enchant_scene.instantiate()
	add_child(int_instance)
	add_child(dex_Instance)
	add_child(str_Instance)
	add_child(curse_instance)
	int_list = int_instance.get_children()
	dex_List = dex_Instance.get_children()
	str_List = str_Instance.get_children()
	curse_list = curse_instance.get_children()
	enchant_list = enchant_instance.get_children()
	popUp = get_node('UI/CanvasLayer/choiceList')
	button = get_node("UI/CanvasLayer/showButton")
	ability_popup = get_node('UI/CanvasLayer/Ability')
	curse_popup = get_node('UI/CanvasLayer/Curse')
	enchant_popup = get_node('UI/CanvasLayer/Enchant')

func _process(delta):
	if !initialized:
		return
	get_node("UI/CanvasLayer/Ability/Reroll_amount").text = str(target.rerolls) + "x"
	get_node("UI/CanvasLayer/Enchant/Reroll_amount").text = str(target.rerolls) + "x"
	get_node("UI/CanvasLayer/Curse/Reroll_amount").text = str(target.rerolls) + "x"

func _input(event):
	if event.is_action_pressed("test"):
		_on_next_enchant()

func _choose_ability_choices(list):
	var choices = []
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var shuffled_list = list.duplicate()
	shuffled_list.shuffle()

	for i in shuffled_list:
		if choices.size() >= 3:
			break
		if choices.find(i) == -1:
			choices.append(i)

	# If we couldn't find enough unique choices, reroll
	if len(choices) < 3:
		return _choose_ability_choices(list)
	else:
		current_ability_choices = choices
		return choices

func _show_enchant_choices():
	enchant_popup.get_node('Choice_1').get_node('Name').text = current_ability_choices[0].i_name
	enchant_popup.get_node('Choice_2').get_node('Name').text = current_ability_choices[1].i_name
	enchant_popup.get_node('Choice_3').get_node('Name').text = current_ability_choices[2].i_name

	enchant_popup.get_node('Choice_1').get_node('Icon').texture = current_ability_choices[0].icon
	enchant_popup.get_node('Choice_2').get_node('Icon').texture = current_ability_choices[1].icon
	enchant_popup.get_node('Choice_3').get_node('Icon').texture = current_ability_choices[2].icon

	enchant_popup.get_node('Choice_1').get_node('ScrollContainer').get_node('Tooltip').text = "[center]" + current_ability_choices[0]._get_tooltip()
	enchant_popup.get_node('Choice_2').get_node('ScrollContainer').get_node('Tooltip').text = "[center]" + current_ability_choices[1]._get_tooltip()
	enchant_popup.get_node('Choice_3').get_node('ScrollContainer').get_node('Tooltip').text = "[center]" + current_ability_choices[2]._get_tooltip()
	enchant_popup.visible = true

	enchant_popup.get_node('Select_1').get_node('Ability_select').visible = false
	enchant_popup.get_node('Select_2').get_node('Ability_select').visible = false
	enchant_popup.get_node('Select_3').get_node('Ability_select').visible = false

func _show_ability_choices():
	ability_popup.get_node('Choice_1').get_node('Name').text = current_ability_choices[0].name
	ability_popup.get_node('Choice_2').get_node('Name').text = current_ability_choices[1].name
	ability_popup.get_node('Choice_3').get_node('Name').text = current_ability_choices[2].name

	ability_popup.get_node('Choice_1').get_node('Icon').texture = current_ability_choices[0].icon
	ability_popup.get_node('Choice_2').get_node('Icon').texture = current_ability_choices[1].icon
	ability_popup.get_node('Choice_3').get_node('Icon').texture = current_ability_choices[2].icon

	for i in current_ability_choices:
		i._update_tooltip()

	ability_popup.get_node('Choice_1').get_node('ScrollContainer').get_node('Tooltip').text = "[center]" + current_ability_choices[0].tooltip
	ability_popup.get_node('Choice_2').get_node('ScrollContainer').get_node('Tooltip').text = "[center]" + current_ability_choices[1].tooltip
	ability_popup.get_node('Choice_3').get_node('ScrollContainer').get_node('Tooltip').text = "[center]" + current_ability_choices[2].tooltip
	ability_popup.visible = true

func _show_curse_choices():
	curse_popup.get_node('Choice_1').get_node('Name').text = current_ability_choices[0].i_name
	curse_popup.get_node('Choice_2').get_node('Name').text = current_ability_choices[1].i_name
	curse_popup.get_node('Choice_3').get_node('Name').text = current_ability_choices[2].i_name

	curse_popup.get_node('Choice_1').get_node('Icon').texture = current_ability_choices[0].icon
	curse_popup.get_node('Choice_2').get_node('Icon').texture = current_ability_choices[1].icon
	curse_popup.get_node('Choice_3').get_node('Icon').texture = current_ability_choices[2].icon

	curse_popup.get_node('Choice_1').get_node('Tooltip').text = "[center]" + current_ability_choices[0].tooltip + "\n\n AC Multiplier: \n " + str(current_ability_choices[0].ascension_currency_multiplier) + "x"
	curse_popup.get_node('Choice_2').get_node('Tooltip').text = "[center]" + current_ability_choices[1].tooltip + "\n\n AC Multiplier: \n " + str(current_ability_choices[1].ascension_currency_multiplier) + "x"
	curse_popup.get_node('Choice_3').get_node('Tooltip').text = "[center]" + current_ability_choices[2].tooltip + "\n\n AC Multiplier: \n " + str(current_ability_choices[2].ascension_currency_multiplier) + "x"
	curse_popup.visible = true

func _on_next_choice(unit, subwave):
	unit.paused = true
	current_ability_round += 1
	var ability_list = []
	target = unit
	is_subwave = subwave
	if unit.get_node("InventoryManager").abilities.size() < 3:
		if unit.type.has("INT"):
			ability_list.append_array(int_list)
		if unit.type.has("DEX"):
			ability_list.append_array(dex_List)
		if unit.type.has("STR"):
			ability_list.append_array(str_List)
		_choose_ability_choices(ability_list)
		_show_ability_choices()
	else:
		_on_next_enchant()

func _on_next_enchant():
	target.paused = true
	chosen_enchant_ability = target.get_node("InventoryManager").abilities.pick_random()
	enchant_popup.get_node('Ability_name').text = "[center]" + chosen_enchant_ability.name
	_choose_enchants_specific(chosen_enchant_ability.tags, chosen_enchant_ability.projectile_type, chosen_enchant_ability, false)
	_show_enchant_choices()

func _on_next_curse():
	target.paused = true
	_choose_ability_choices(curse_list)
	_show_curse_choices()

func _on_button_pressed():
	popUp.visible = true
	button.visible = false	

func _on_character_selected(unit):
	picked.connect(unit.get_node("InventoryManager")._on_ability_manager_picked)
	enchant_picked.connect(unit.get_node("InventoryManager")._on_enchant_picked)
	target = unit

func _load_abilities(abilities):
	for i in range(abilities.size()):
		var current_ability_data = abilities[i]
		_create_ability_based_on_type(current_ability_data['type'], current_ability_data)

func _create_ability_based_on_type(type, ability_data):
	var created_ability = null
	if "INT" in type:
		for i in range(int_list.size()):
			if int_list[i].a_name == ability_data['name']:
				created_ability = int_list[i].duplicate()
				int_list.erase(int_list[i])
				break
	if "DEX" in type and created_ability == null:
		for i in range(dex_List.size()):
			if dex_List[i].a_name == ability_data['name']:
				created_ability = dex_List[i].duplicate()
				dex_List.erase(dex_List[i])
				break
	if "STR" in type and created_ability == null:
		for i in range(str_List.size()):
			if str_List[i].a_name == ability_data['name']:
				created_ability = str_List[i].duplicate()
				str_List.erase(str_List[i])
				break

	picked.emit(created_ability, is_subwave)
	chosen_ability_choices.append(created_ability)
	for level in ability_data['level'] - 1:
		created_ability._add_level()

func _on_enchant_1_pressed(event, index):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if target.get_node("InventoryManager").abilities.size() > index:
				if !is_subwave:
					enchant_mode = true
					enchant_picked.emit(current_ability_choices[enchant_index], index, enchant_mode)
				else:
					enchant_mode = false
					enchant_picked.emit(current_ability_choices[enchant_index], index, enchant_mode)
				chosen_enchants.append(current_ability_choices[enchant_index].name)
				if current_ability_choices[enchant_index].unique:
					removed_enchants.append(current_ability_choices[enchant_index].name)
					enchant_list.erase(current_ability_choices[enchant_index])
				enchant_popup.visible = false
				target.paused = false

func _use_ability_based_on_name(name):
	var all_lists = []
	all_lists.append_array(int_list)
	all_lists.append_array(dex_List)
	all_lists.append_array(str_List)
	for i in all_lists:
		if i.a_name == name:
			var created_ability = i.duplicate()
			created_ability.unit = target
			created_ability._initialize()
			created_ability.forced_closest = true
			created_ability._use()
			return

func _choose_enchants_specific(tags, projectile_type, ability, enchantMode = true):
	chosen_enchant_ability = ability
	reroll_mode = enchantMode
	enchant_popup.get_node('Ability_name').text = "[center]" + chosen_enchant_ability.name
	randomize()
	var roll = randi_range(0, 100)
	enchant_list.shuffle()
	while true:
		# Reset choices at the start of each attempt
		var choices = []
		# Go through each enchant in the enchant list
		for i in enchant_list:
			# Check if it's rare enough
			if i._get_rarity() > roll or choices.find(i) != -1:
				continue
			# Check if it matches any tag and if it's a projectile type
			for j in tags:
				if has_common_substring(j, i.tags[0]):
					if i.types.find(projectile_type) != -1 or i.types.find(-1) != -1:
						roll = randi_range(0, 100)
						choices.append(i)

			# Check if it matches the projectile type
				if i.types.find(projectile_type) != -1 and choices.find(i) == -1:
					roll = randi_range(0, 100)
					choices.append(i)
		
		var unique_choices = []
		for i in choices:
			if unique_choices.find(i) == -1:
				unique_choices.append(i)
					
		# Check for at least 3 unique enchants
		if len(unique_choices) >= 3:
			current_ability_choices = unique_choices.slice(0, 3)  # Take the first three unique choices
			break  # Exit the loop once valid choices are found
		else:
			roll = randi_range(0, 100)  # Reroll the rarity if not enough unique choices are found

	# Set the selected enchants and show them
	_show_enchant_choices()
	
func split_tag(tag: String) -> Array:
	var substrings = []
	var current_word = ""
	
	for i in range(tag.length()):
		var char = tag[i]
		if char == char.to_upper() and current_word != "":
			substrings.append(current_word)
			current_word = char
		else:
			current_word += char
	
	if current_word != "":
		substrings.append(current_word)
	
	return substrings

func has_common_substring(tag1: String, tag2: String) -> bool:
	var split1 = split_tag(tag1)
	var split2 = split_tag(tag2)
	
	# Check for any common substring by iterating through one array and checking the other
	for substring in split1:
		if substring in split2 and substring != "Damage" and substring != "Explosion":
			return true
	# Exceptions:
		if substring == "Freeze" and "Frozen" in split2:
			return true
			
	return false

# This function is used to use an ability based on the type of the ability.
# Types: 0 = line, 1 = enemy target, 2 = ally target, 3 = area, 4 = passive, 5 = self, 6 = movement, 7 = enemy aura, 8 = ally aura, 9 = summon, 10 = none
func _use_ability_based_on_type(type):
	var all_lists = []
	all_lists.append_array(int_list)
	all_lists.append_array(dex_List)
	all_lists.append_array(str_List)
	all_lists.shuffle()
	for i in all_lists:
		if type.find(i.projectile_type) != -1:
			var created_ability = i.duplicate()
			created_ability.unit = target
			created_ability._initialize()
			created_ability.forced_closest = true
			created_ability._use()
			return

func _open_enchant_ability_select(index):
	enchant_index = index
	# Check if the enchant is for a specific leveled up ability
	var ind = target.get_node("InventoryManager").abilities.find(chosen_enchant_ability)
	if !is_subwave:
		enchant_mode = true
		enchant_picked.emit(current_ability_choices[enchant_index], ind, enchant_mode)
	else:
		enchant_mode = false
		enchant_picked.emit(current_ability_choices[enchant_index], ind, enchant_mode)
	enchant_popup.visible = false
	if current_ability_choices[enchant_index].unique:
		removed_enchants.append(current_ability_choices[enchant_index].name)
		enchant_list.erase(current_ability_choices[enchant_index])
	target.paused = false

func _level_up_enchant(tags, projectile_type, ability, enchantMode = true):
	enchant_mode = false
	is_subwave = true
	_choose_enchants_specific(tags, projectile_type, ability, enchantMode)

func _on_select_1_pressed(index):
	current_ability_choices[index].level_enchant.connect(_level_up_enchant)
	picked.emit(current_ability_choices[index], is_subwave)
	chosen_ability_choices.append(current_ability_choices[index])

	if int_list.find(current_ability_choices[index]) != -1:
		int_list.erase(current_ability_choices[index])
	if dex_List.find(current_ability_choices[index]) != -1:
		dex_List.erase(current_ability_choices[index])
	if str_List.find(current_ability_choices[index]) != -1:
		str_List.erase(current_ability_choices[index])

	ability_popup.visible = false
	target.paused = false

func _on_reroll_pressed():
	if target.rerolls > 0:
		target.rerolls -= 1
		var ability_list = []
		if target.type.has("INT"):
			ability_list.append_array(int_list)
		if target.type.has("DEX"):
			ability_list.append_array(dex_List)
		if target.type.has("STR"):
			ability_list.append_array(str_List)
		_choose_ability_choices(ability_list)
		_show_ability_choices()
	else:
		Utility.get_node("ErrorMessage")._create_error_message("You have no rerolls left", target)
	
func _on_reroll_enchants_pressed():
	if !reroll_mode:
		if target.rerolls > 0:
			target.rerolls -= 1
			chosen_enchant_ability = target.get_node("InventoryManager").abilities.pick_random()
			enchant_popup.get_node('Ability_name').text = "[center]" + chosen_enchant_ability.name
			_choose_enchants_specific(chosen_enchant_ability.tags, chosen_enchant_ability.projectile_type, chosen_enchant_ability, reroll_mode)
		else:
			Utility.get_node("ErrorMessage")._create_error_message("You have no rerolls left", target)
	else:
		if target.rerolls > 0:
			target.rerolls -= 1
			_choose_enchants_specific(chosen_enchant_ability.tags, chosen_enchant_ability.projectile_type, chosen_enchant_ability, reroll_mode)
		else:
			Utility.get_node("ErrorMessage")._create_error_message("You have no rerolls left", target)

func _on_curse_1_selected(index):
	curse_picked.emit(current_ability_choices[index])
	chosen_curses.append(current_ability_choices[index].name)
	if "special" in current_ability_choices[index]:
		curse_list.erase(current_ability_choices[index])
		removed_curses.append(current_ability_choices[index].name)
	curse_popup.visible = false
	target.ascension_currency_multiplier += current_ability_choices[index].ascension_currency_multiplier
	target.paused = false

func _on_curse_reroll_pressed():
	if target.rerolls > 0:
		target.rerolls -= 1
		_choose_ability_choices(curse_list)
		_show_curse_choices()
	else:
		Utility.get_node("ErrorMessage")._create_error_message("You have no rerolls left", target)

func _load_curses():
	if chosen_curses.size() > 0:
		for i in chosen_curses:
			for j in curse_list:
				if j.name == i:
					loaded_curses.append(j)

	if removed_curses.size() > 0:
		for i in removed_curses:
			for j in curse_list:
				if j.name == i:
					curse_list.erase(j)

func _load_enchants():
	if chosen_enchants.size() > 0:
		for i in chosen_enchants:
			for j in enchant_list:
				if j.name == i:
					loaded_enchants.append(j)

	if removed_enchants.size() > 0:
		for i in removed_enchants:
			for j in enchant_list:
				if j.name == i:
					enchant_list.erase(j)
	
func save():
	var save_dict = {
		"filename" : get_path(),
		"parent" : get_parent().get_path(),
		"reroll_amount": reroll_amount,
		"chosen_ability_choices": chosen_ability_choices,
		"current_ability_round": current_ability_round,
		"chosen_curses": chosen_curses,
		"removed_curses": removed_curses,
		"chosen_enchants": chosen_enchants,
		"removed_enchants": removed_enchants
	}
	return save_dict
