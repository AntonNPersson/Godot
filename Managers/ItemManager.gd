extends Node
@export var bot : PackedScene
@export var second_mid : PackedScene
@export var mid : PackedScene
@export var top : PackedScene
@export var item : PackedScene
@export var potion_scene : PackedScene

var player = null

var bot_list
var second_mid_list
var mid_list
var top_list
var second_top_list
var unique_list
var legendary_list

# Test
var second_mid_list_offense
var second_mid_list_defense
var second_mid_list_utility

var mid_list_offense
var mid_list_defense
var mid_list_utility

var top_list_offense
var top_list_defense
var top_list_utility

var starting_items = 0
var weapon_list = [14, 15, 16, 17, 18, 19, 20] # 14 = Greataxe, 15 = Bow, 16 = Crossbow, 17 = Scepter, 18 = Staff, 19 = Sword, 20 = Dagger
var evade_armor_list = [0, 1, 2, 3, 4]
var barrier_armor_list = [5, 6, 7, 8, 9]
var armor_armor_list = [10, 11, 12, 13]
var potion_list

var last_items = []

const ITEM_RARITY = {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	EPIC = 3,
	LEGENDARY = 4,
	UNIQUE = 5
}

var RARE_STAT_INCREASE = 1.1
var EPIC_STAT_INCREASE = 1.3

# Called when the node enters the scene tree for the first time. vres://Items/Mid Effects/Mid effects list.tscn
func _initialize():
	var bot_instance = bot.instantiate()
	var mid_instance = preload('res://Items/Low-Mid Effects/lowmidlist.tscn').instantiate()
	var second_mid = preload('res://Items/Low-Mid Effects/lowmidlist2.tscn').instantiate()
	var top_instance = preload('res://Items/Mid Effects/Mid effects list.tscn').instantiate()
	var second_top = preload('res://Items/Top Effects/top list effects.tscn').instantiate()
	var potion_instance = preload('res://Items/Potions/potion list.tscn').instantiate()
	var unique_instance = preload('res://Items/Unique Effects/Lists/unique list.tscn').instantiate()
	var legendary_instance = preload('res://Items/Legendary Effects/Lists/legendary list.tscn').instantiate()

	var second_mid_list_offense_scene = preload("res://Items/Low-Mid Effects/lists/low_mid_offense.tscn").instantiate()
	var second_mid_list_defense_scene = preload("res://Items/Low-Mid Effects/lists/low_mid_defense.tscn").instantiate()
	var second_mid_list_utility_scene = preload("res://Items/Low-Mid Effects/lists/low_mid_utility.tscn").instantiate()

	var mid_list_offense_scene = preload("res://Items/Low-Mid Effects/lists/second_low_mid_offense.tscn").instantiate()
	var mid_list_defense_scene = preload("res://Items/Low-Mid Effects/lists/second_low_mid_defense.tscn").instantiate()
	var mid_list_utility_scene = preload("res://Items/Low-Mid Effects/lists/second_low_mid_utlity.tscn").instantiate()

	var top_list_offense_scene = preload("res://Items/Mid Effects/lists/mid_effect_offensive.tscn").instantiate()
	var top_list_defense_scene = preload("res://Items/Mid Effects/lists/mid_effect_defensive.tscn").instantiate()
	var top_list_utility_scene = preload("res://Items/Mid Effects/lists/mid_effect_utility.tscn").instantiate()

	second_mid_list_offense = second_mid_list_offense_scene.get_children()
	second_mid_list_defense = second_mid_list_defense_scene.get_children()
	second_mid_list_utility = second_mid_list_utility_scene.get_children()

	mid_list_offense = mid_list_offense_scene.get_children()
	mid_list_defense = mid_list_defense_scene.get_children()
	mid_list_utility = mid_list_utility_scene.get_children()

	top_list_offense = top_list_offense_scene.get_children()
	top_list_defense = top_list_defense_scene.get_children()
	top_list_utility = top_list_utility_scene.get_children()

	bot_list = bot_instance.get_children()
	second_mid_list = second_mid.get_children()
	mid_list = mid_instance.get_children()
	top_list = top_instance.get_children()
	second_top_list = second_top.get_children()
	potion_list = potion_instance.get_children()
	unique_list = unique_instance.get_children()
	legendary_list = legendary_instance.get_children()

	get_node('Items').add_child(second_mid_list_offense_scene)
	get_node('Items').add_child(second_mid_list_defense_scene)
	get_node('Items').add_child(second_mid_list_utility_scene)

	get_node('Items').add_child(mid_list_offense_scene)
	get_node('Items').add_child(mid_list_defense_scene)
	get_node('Items').add_child(mid_list_utility_scene)

	get_node('Items').add_child(top_list_offense_scene)
	get_node('Items').add_child(top_list_defense_scene)
	get_node('Items').add_child(top_list_utility_scene)

	get_node('Items').add_child(bot_instance)
	get_node('Items').add_child(second_mid)
	get_node('Items').add_child(mid_instance)
	get_node('Items').add_child(top_instance)
	get_node('Items').add_child(second_top)
	get_node('Items').add_child(potion_instance)
	get_node('Items').add_child(unique_instance)
	get_node('Items').add_child(legendary_instance)
	bot_instance.global_position = Vector2(-10000, -10000)
	second_mid.global_position = Vector2(-10000, -10000)
	mid_instance.global_position = Vector2(-10000, -10000)
	top_instance.global_position = Vector2(-10000, -10000)
	second_top.global_position = Vector2(-10000, -10000)

	if !GameManager.is_save_file:
		for i in range(0, 3):
			_add_to_inventory()
		if GameManager.selected_character_name == "Explorer":
			_add_specific_to_inventory(19)
		elif GameManager.selected_character_name == "Berserker":
			_add_specific_to_inventory(14)
		elif GameManager.selected_character_name == "Ranger":
			_add_specific_to_inventory(16)
		elif GameManager.selected_character_name == "Mage":
			_add_specific_to_inventory(18)
		elif GameManager.selected_character_name == "Warrior":
			_add_specific_to_inventory(19)
		elif GameManager.selected_character_name == "Duelist":
			_add_specific_to_inventory(20)
		elif GameManager.selected_character_name == "Sentinel":
			_add_specific_to_inventory(17)
		elif GameManager.selected_character_name == "Chronomancer":
			_add_specific_to_inventory(18)
		
		_add_potion_to_inventory("Mana")
		_add_potion_to_inventory("Health")
		player.get_node('InventoryManager').current_potion_charges[0] = player.get_node('InventoryManager').potion_charges[0]
		player.get_node('InventoryManager').current_potion_charges[1] = player.get_node('InventoryManager').potion_charges[1]

func _calculate_item_rarity():
	randomize()
	var roll = randi() % 100
	
	# Check if an item will drop (70% chance of no drop)
	if roll > 30:
		return null  # No item drop

	# Define base rarity chances
	var base_rarity_chances = {
		ITEM_RARITY.COMMON: 60.0,
		ITEM_RARITY.UNCOMMON: 29.25,
		ITEM_RARITY.RARE: 10,
		ITEM_RARITY.EPIC: 100.0,
		ITEM_RARITY.UNIQUE: 0.5,
		ITEM_RARITY.LEGENDARY: 0.25
	}

	var adjusted_rarity_chances = {}
	var redistribution_pool = 0.0

	adjusted_rarity_chances[ITEM_RARITY.COMMON] = base_rarity_chances[ITEM_RARITY.COMMON]
	adjusted_rarity_chances[ITEM_RARITY.UNCOMMON] = base_rarity_chances[ITEM_RARITY.UNCOMMON]
	adjusted_rarity_chances[ITEM_RARITY.RARE] = base_rarity_chances[ITEM_RARITY.RARE]
	adjusted_rarity_chances[ITEM_RARITY.EPIC] = base_rarity_chances[ITEM_RARITY.EPIC]
	adjusted_rarity_chances[ITEM_RARITY.UNIQUE] = base_rarity_chances[ITEM_RARITY.UNIQUE]
	adjusted_rarity_chances[ITEM_RARITY.LEGENDARY] = base_rarity_chances[ITEM_RARITY.LEGENDARY]

	# Start with Common and Uncommon being the first to reduce

	var reduced_common_chance = base_rarity_chances[ITEM_RARITY.COMMON] - (player.item_drop_chance_multiplier - 1.0) * base_rarity_chances[ITEM_RARITY.COMMON]
	adjusted_rarity_chances[ITEM_RARITY.COMMON] = max(0.0, reduced_common_chance)
	redistribution_pool += max(0.0, -reduced_common_chance)

	if player.item_drop_chance_multiplier >= 2.0:
		# Uncommon chance is reduced to 0 at 2x multiplier
		var reduced_uncommon_chance = base_rarity_chances[ITEM_RARITY.UNCOMMON] - (player.item_drop_chance_multiplier - 1.0) * base_rarity_chances[ITEM_RARITY.UNCOMMON]
		adjusted_rarity_chances[ITEM_RARITY.UNCOMMON] = max(0.0, reduced_uncommon_chance)
		redistribution_pool += max(0.0, -reduced_uncommon_chance)

	# Continue adjusting the chances based on the multiplier
	if player.item_drop_chance_multiplier > 2.0:
		# Rare chance is reduced at higher multipliers
		var reduced_rare_chance = base_rarity_chances[ITEM_RARITY.RARE] - (player.item_drop_chance_multiplier - 2.0) * base_rarity_chances[ITEM_RARITY.RARE]
		adjusted_rarity_chances[ITEM_RARITY.RARE] = max(0.0, reduced_rare_chance)
		redistribution_pool += max(0.0, -reduced_rare_chance)

	if player.item_drop_chance_multiplier > 3.0:
		# Continue reducing Rare, distributing excess to the remaining rarities
		var reduced_epic_chance = base_rarity_chances[ITEM_RARITY.EPIC] - (player.item_drop_chance_multiplier - 3.0) * base_rarity_chances[ITEM_RARITY.EPIC]
		adjusted_rarity_chances[ITEM_RARITY.EPIC] = max(0.0, reduced_epic_chance)
		redistribution_pool += max(0.0, -reduced_epic_chance)

	# At this point, we need to redistribute the removed chances to the higher rarities
	# First, we calculate the total base chances of the remaining rarities
	var remaining_rarities = []
	for rarity in adjusted_rarity_chances.keys():
		if adjusted_rarity_chances[rarity] > 0:
			remaining_rarities.append(rarity)

	# Calculate total base chance of remaining rarities
	var total_remaining_base_chance = 0.0
	for rarity in remaining_rarities:
		total_remaining_base_chance += base_rarity_chances[rarity]

	# Redistribute the excess pool proportionally to the remaining rarities
	for rarity in remaining_rarities:
		var base_chance = base_rarity_chances[rarity]
		adjusted_rarity_chances[rarity] += (base_chance / total_remaining_base_chance) * redistribution_pool

	# Ensure total chances add up to 100%
	var total_chance = 0.0
	for chance in adjusted_rarity_chances.values():
		total_chance += chance

	if total_chance != 100.0:
		var correction = 100.0 - total_chance
		var correction_per_rarity = correction / remaining_rarities.size()
		for rarity in remaining_rarities:
			adjusted_rarity_chances[rarity] += correction_per_rarity

	# Use the same roll to determine rarity
	roll = randi() % 100
	for rarity in adjusted_rarity_chances.keys():
		if roll < adjusted_rarity_chances[rarity]:
			return rarity
		roll -= adjusted_rarity_chances[rarity]
	

	# Fallback (should not reach this point)
	return ITEM_RARITY.COMMON



func _get_previous_rarity(current_rarity):
	var rarity_order = [
		ITEM_RARITY.COMMON,
		ITEM_RARITY.UNCOMMON,
		ITEM_RARITY.RARE,
		ITEM_RARITY.EPIC,
		ITEM_RARITY.UNIQUE,
		ITEM_RARITY.LEGENDARY
	]
	var index = rarity_order.find(current_rarity)
	if index > 0:
		return rarity_order[index - 1]
	return null

func _balance_item_drops():
	if last_items.size() >= 3:
		var count_weapons = 0
		for i in range(weapon_list.size()):
			if last_items.find(bot_list[weapon_list[i]]) == -1:
				count_weapons += 1
		if count_weapons == 0:
			var weapon = bot_list[weapon_list.pick_random()].duplicate()
			last_items.clear()
			return weapon
		elif count_weapons == last_items.size():
			var armor_array = []
			for j in range(bot_list.size()):
				if j not in weapon_list:
					armor_array.append(j)
			var armor = bot_list[armor_array.pick_random()].duplicate()
			last_items.clear()
			return armor
	return null
			
func _create_item(_rarity = null):
	var rarity = _calculate_item_rarity()
	if _rarity != null:
		rarity = _rarity
	if rarity == ITEM_RARITY.COMMON:
		var bot_piece = bot_list[randi() % bot_list.size()].duplicate()
		last_items.append(bot_list.find(bot_piece))
		var new_bot_piece = _balance_item_drops()
		if new_bot_piece != null:
			bot_piece = new_bot_piece
		bot_piece._initialize()
		bot_piece._ascend(player.item_power)
		var _item = item.instantiate()
		_item.i_name = bot_piece.name
		_item.player = player
		_item.rarity = ITEM_RARITY.COMMON
		_item.im = self
		_item.add_child(bot_piece)
		bot_piece.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
		add_child(_item)
		return _item
	elif rarity == ITEM_RARITY.UNCOMMON:
		var bot_piece = bot_list[randi() % bot_list.size()].duplicate()
		last_items.append(bot_list.find(bot_piece))
		var new_bot_piece = _balance_item_drops()
		if new_bot_piece != null:
			bot_piece = new_bot_piece
		bot_piece._initialize()
		var full_list_mid = []
		var full_list_second_mid = []
		var mid_piece
		var second_mid_piece

		if bot_piece.type.find('Offense') != -1:
			full_list_second_mid.append_array(second_mid_list_offense)
			full_list_mid.append_array(mid_list_offense)
		if bot_piece.type.find('Defense') != -1:
			full_list_second_mid.append_array(second_mid_list_defense)
			full_list_mid.append_array(mid_list_defense)
		if bot_piece.type.find('Utility') != -1:
			full_list_second_mid.append_array(second_mid_list_utility)
			full_list_mid.append_array(mid_list_utility)
		if bot_piece.type.find('All') != -1:
			full_list_second_mid.append_array(second_mid_list)
			full_list_mid.append_array(mid_list)
		
		second_mid_piece = full_list_second_mid[randi() % full_list_second_mid.size()].duplicate()
		mid_piece = full_list_mid[randi() % full_list_mid.size()].duplicate()

		second_mid_piece._initialize()
		mid_piece._initialize()
		second_mid_piece._ascend(player.item_power)
		bot_piece._ascend(player.item_power)
		mid_piece._ascend(player.item_power)
		var _item = item.instantiate()
		_item.i_name = bot_piece.name + " of " + second_mid_piece.name + " " + mid_piece.name
		_item.player = player
		_item.rarity = ITEM_RARITY.UNCOMMON
		_item.im = self
		_item.add_child(bot_piece)
		_item.add_child(second_mid_piece)
		_item.add_child(mid_piece)
		bot_piece.set_owner(_item)
		second_mid_piece.set_owner(_item)
		mid_piece.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
		add_child(_item)
		return _item
	elif rarity == ITEM_RARITY.RARE:
		var bot_piece = bot_list[randi() % bot_list.size()].duplicate()
		last_items.append(bot_list.find(bot_piece))
		var new_bot_piece = _balance_item_drops()
		if new_bot_piece != null:
			bot_piece = new_bot_piece
		bot_piece._initialize()
		var full_list_second_mid = []
		var full_list_mid = []
		var full_list_top = []
		var second_mid_piece
		var mid_piece
		var top_piece

		if bot_piece.type.find('Offense') != -1:
			full_list_second_mid.append_array(second_mid_list_offense)
			full_list_mid.append_array(mid_list_offense)
			full_list_top.append_array(top_list_offense)
		if bot_piece.type.find('Defense') != -1:
			full_list_second_mid.append_array(second_mid_list_defense)
			full_list_mid.append_array(mid_list_defense)
			full_list_top.append_array(top_list_defense)
		if bot_piece.type.find('Utility') != -1:
			full_list_second_mid.append_array(second_mid_list_utility)
			full_list_mid.append_array(mid_list_utility)
			full_list_top.append_array(top_list_utility)
		if bot_piece.type.find('All') != -1:
			full_list_second_mid.append_array(second_mid_list)
			full_list_mid.append_array(mid_list)
			full_list_top.append_array(top_list)

		second_mid_piece = full_list_second_mid[randi() % full_list_second_mid.size()].duplicate()
		mid_piece = full_list_mid[randi() % full_list_mid.size()].duplicate()
		top_piece = full_list_top[randi() % full_list_top.size()].duplicate()

		second_mid_piece._initialize()
		mid_piece._initialize()	
		top_piece._initialize()
		second_mid_piece._ascend(player.item_power)
		bot_piece._ascend(player.item_power)
		mid_piece._ascend(player.item_power)
		bot_piece._increase_rarity(RARE_STAT_INCREASE, 2)
		var _item = item.instantiate()
		_item.i_name = bot_piece.name + " of " + second_mid_piece.name + " " + mid_piece.name + " and " + top_piece.name
		_item.player = player
		_item.rarity = ITEM_RARITY.RARE
		_item.im = self
		_item.add_child(bot_piece)
		_item.add_child(second_mid_piece)
		_item.add_child(mid_piece)
		_item.add_child(top_piece)
		bot_piece.set_owner(_item)
		second_mid_piece.set_owner(_item)
		mid_piece.set_owner(_item)
		top_piece.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
		add_child(_item)
		return _item
	elif rarity == ITEM_RARITY.EPIC:
		var bot_piece = bot_list[randi() % bot_list.size()].duplicate()
		last_items.append(bot_list.find(bot_piece))
		var new_bot_piece = _balance_item_drops()
		if new_bot_piece != null:
			bot_piece = new_bot_piece
		bot_piece._initialize()
		var full_list_second_mid = []
		var full_list_mid = []
		var full_list_top = []
		var second_mid_piece
		var mid_piece
		var top_piece
		if bot_piece.type.find('Offense') != -1:
			full_list_second_mid.append_array(second_mid_list_offense)
			full_list_mid.append_array(mid_list_offense)
			full_list_top.append_array(top_list_offense)
		if bot_piece.type.find('Defense') != -1:
			full_list_second_mid.append_array(second_mid_list_defense)
			full_list_mid.append_array(mid_list_defense)
			full_list_top.append_array(top_list_defense)
		if bot_piece.type.find('Utility') != -1:
			full_list_second_mid.append_array(second_mid_list_utility)
			full_list_mid.append_array(mid_list_utility)
			full_list_top.append_array(top_list_utility)
		if bot_piece.type.find('All') != -1:
			full_list_second_mid.append_array(second_mid_list)
			full_list_mid.append_array(mid_list)
			full_list_top.append_array(top_list)

		second_mid_piece = full_list_second_mid[randi() % full_list_second_mid.size()].duplicate()
		mid_piece = full_list_mid[randi() % full_list_mid.size()].duplicate()
		top_piece = full_list_top[randi() % full_list_top.size()].duplicate()
	
		var visible_second_top_list = []
		for i in range(second_top_list.size()):
			if second_top_list[i].visible:
				visible_second_top_list.append(second_top_list[i])
		var second_top_piece = visible_second_top_list[randi() % visible_second_top_list.size()].duplicate()
		second_mid_piece._initialize()
		mid_piece._initialize()
		top_piece._initialize()
		second_top_piece._initialize()
		second_mid_piece._ascend(player.item_power)
		bot_piece._ascend(player.item_power)
		mid_piece._ascend(player.item_power)
		bot_piece._increase_rarity(EPIC_STAT_INCREASE, 4)
		var _item = item.instantiate()
		_item.i_name = second_top_piece.name + ", " + bot_piece.name + " of " + second_mid_piece.name + " " + mid_piece.name + " and " + top_piece.name
		_item.player = player
		_item.rarity = ITEM_RARITY.EPIC
		_item.im = self
		_item.add_child(bot_piece)
		_item.add_child(second_mid_piece)
		_item.add_child(mid_piece)
		_item.add_child(top_piece)
		_item.add_child(second_top_piece)
		bot_piece.set_owner(_item)
		second_mid_piece.set_owner(_item)
		mid_piece.set_owner(_item)
		top_piece.set_owner(_item)
		second_top_piece.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
		add_child(_item)
		return _item
	elif rarity == ITEM_RARITY.UNIQUE:
		var unique_piece = unique_list[randi() % unique_list.size()].duplicate()
		unique_piece._initialize()
		unique_piece._ascend(player.item_power)

		var bot_piece
		if unique_piece.unique_type == "Weapon":
			bot_piece = bot_list[weapon_list.pick_random()].duplicate()
		bot_piece._initialize()
		bot_piece._ascend(player.item_power)

		var second_top_piece = second_top_list[randi() % top_list.size()].duplicate()
		second_top_piece._initialize()
		var _item = item.instantiate()
		_item.i_name = second_top_piece.name + ", " + bot_piece.name + " of " + unique_piece.name
		_item.player = player
		_item.rarity = ITEM_RARITY.UNIQUE
		_item.im = self
		_item.add_child(bot_piece)
		_item.add_child(unique_piece)
		_item.add_child(second_top_piece)
		bot_piece.set_owner(_item)
		second_top_piece.set_owner(_item)
		unique_piece.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
		add_child(_item)
		return _item
	elif rarity == ITEM_RARITY.LEGENDARY:
		var legendary_piece = legendary_list[randi() % legendary_list.size()].duplicate()
		legendary_piece._initialize()
		legendary_piece._ascend(player.item_power)

		var bot_piece = bot_list[randi() % bot_list.size()].duplicate()
		bot_piece._initialize()
		bot_piece._ascend(player.item_power)

		var _item = item.instantiate()
		_item.i_name = legendary_piece.name
		_item.player = player
		_item.rarity = ITEM_RARITY.LEGENDARY
		_item.im = self
		_item.add_child(bot_piece)
		_item.add_child(legendary_piece)
		legendary_piece.set_owner(_item)
		bot_piece.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
		add_child(_item)
		return _item

func _load_item(bot_piece_data, second_mid_piece_data, mid_piece_data, top_piece_data, second_top_piece_data, item_name, rarity):
	var bot_piece
	var second_mid_piece
	var mid_piece
	var top_piece
	var second_top_piece
	var item_ = item.instantiate()
	item_.i_name = item_name
	item_.player = player
	item_.rarity = rarity
	item_.im = self

	if bot_piece_data != null:
		var bot_piece_index = _find_item_in_list(bot_piece_data["name"], bot_list)
		bot_piece = bot_list[bot_piece_index].duplicate()
		bot_piece._initialize()
		for i in range(bot_piece_data["values"].size()):
			bot_piece.set(bot_piece_data["tags"][i], bot_piece_data["values"][i])
		bot_piece.set_owner(item_)
		item_.add_child(bot_piece)
	if second_mid_piece_data != null:
		var second_mid_piece_index = _find_item_in_list(second_mid_piece_data["name"], second_mid_list)
		second_mid_piece = second_mid_list[second_mid_piece_index].duplicate()
		if rarity == ITEM_RARITY.LEGENDARY:
			second_mid_piece_index = _find_item_in_list(second_mid_piece_data["name"], legendary_list)
			second_mid_piece = legendary_list[second_mid_piece_index].duplicate()
		elif rarity == ITEM_RARITY.UNIQUE:
			second_mid_piece_index = _find_item_in_list(second_mid_piece_data["name"], unique_list)
			second_mid_piece = unique_list[second_mid_piece_index].duplicate()
		second_mid_piece._initialize()
		for i in range(second_mid_piece_data["values"].size()):
			second_mid_piece.set(second_mid_piece_data["tags"][i], second_mid_piece_data["values"][i])
		second_mid_piece.set_owner(item_)
		item_.add_child(second_mid_piece)
	if mid_piece_data != null:
		var mid_piece_index = _find_item_in_list(mid_piece_data["name"], mid_list)
		mid_piece = mid_list[mid_piece_index].duplicate()
		if rarity == ITEM_RARITY.UNIQUE:
			mid_piece_index = _find_item_in_list(mid_piece_data["name"], second_top_list)
			mid_piece = second_top_list[mid_piece_index].duplicate()
		mid_piece._initialize()
		for i in range(mid_piece_data["values"].size()):
			mid_piece.set(mid_piece_data["tags"][i], mid_piece_data["values"][i])
		mid_piece.set_owner(item_)
		item_.add_child(mid_piece)
	if top_piece_data != null:
		var top_piece_index = _find_item_in_list(top_piece_data["name"], top_list)
		top_piece = top_list[top_piece_index].duplicate()
		top_piece._initialize()
		top_piece.set_owner(item_)
		item_.add_child(top_piece)
	if second_top_piece_data != null:
		var second_top_piece_index = _find_item_in_list(second_top_piece_data["name"], second_top_list)
		second_top_piece = second_top_list[second_top_piece_index].duplicate()
		second_top_piece._initialize()
		second_top_piece.set_owner(item_)
		item_.add_child(second_top_piece)
	
	item_._initialize()
	item_.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
	item_._picked_up = true
	player.get_node('InventoryManager').get_node('Items').add_child(item_)
	item_.get_child(0).get_child(0).visible = false
	item_.get_child(0).get_child(1).visible = false
	item_.get_child(1).visible = false
	return item_

func _load_potion(potion_name, potion_rarity):
	var potion = potion_list[_find_item_in_list_item_name(potion_name, potion_list)].duplicate()
	potion.player = player
	potion._initialize()
	potion._ascend(player.item_power)
	var _item = potion_scene.instantiate()
	_item.i_name = potion.i_name
	_item.player = player
	_item.rarity = potion_rarity
	_item.im = self
	_item.charges = potion.charges
	_item.type = potion.type
	_item.add_child(potion)
	potion.set_owner(_item)
	_item._initialize()
	_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
	_item._picked_up = true
	player.get_node('InventoryManager').get_node('Items').add_child(_item)
	_item.get_child(0).get_child(0).visible = false
	_item.get_child(0).get_child(1).visible = false
	_item.get_child(1).visible = false
	return _item


func _find_item_in_list(item_name, list):
	for i in range(list.size()):
		if list[i].name == item_name:
			return i
	return -1

func _find_item_in_list_item_name(item_name, list):
	for i in range(list.size()):
		list[i]._initialize()
		if list[i].i_name == item_name:
			return i
	return -1

func _create_health_potion(_rarity = null):
	var rarity = _calculate_item_rarity()
	if _rarity != null:
		rarity = _rarity

	rarity = ITEM_RARITY.UNCOMMON
	if rarity == ITEM_RARITY.COMMON:
		var potion = potion_list[0].duplicate()
		potion.player = player
		potion._initialize()
		potion._ascend(player.item_power)
		var _item = potion_scene.instantiate()
		_item.i_name = potion.i_name
		_item.player = player
		_item.rarity = ITEM_RARITY.COMMON
		_item.im = self
		_item.charges = potion.charges
		_item.type = "Health"
		_item.add_child(potion)
		potion.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
		return _item
	elif rarity == ITEM_RARITY.UNCOMMON:
		var potion = potion_list[4].duplicate()
		potion.player = player
		potion._initialize()
		potion._ascend(player.item_power)
		var _item = potion_scene.instantiate()
		_item.i_name = potion.i_name
		_item.player = player
		_item.rarity = ITEM_RARITY.UNCOMMON
		_item.im = self
		_item.charges = potion.charges
		_item.type = "Health"
		_item.add_child(potion)
		potion.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
		return _item
	return null

func _create_mana_potion(_rarity = null):
	var rarity = _calculate_item_rarity()
	if _rarity != null:
		rarity = _rarity

	rarity = ITEM_RARITY.UNCOMMON
	if rarity == ITEM_RARITY.COMMON:
		var potion = potion_list[1].duplicate()
		potion.player = player
		potion._initialize()
		potion._ascend(player.item_power)
		var _item = potion_scene.instantiate()
		_item.i_name = potion.i_name
		_item.player = player
		_item.rarity = ITEM_RARITY.COMMON
		_item.im = self
		_item.charges = potion.charges
		_item.type = "Mana"
		_item.add_child(potion)
		potion.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
		return _item
	elif rarity == ITEM_RARITY.UNCOMMON:
		var potion = potion_list[5].duplicate()
		potion.player = player
		potion._initialize()
		potion._ascend(player.item_power)
		var _item = potion_scene.instantiate()
		_item.i_name = potion.i_name
		_item.player = player
		_item.rarity = ITEM_RARITY.UNCOMMON
		_item.im = self
		_item.charges = potion.charges
		_item.type = "Mana"
		_item.add_child(potion)
		potion.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
		return _item
	return null

func _create_barrier_potion(_rarity = null):
	var rarity = _calculate_item_rarity()
	if _rarity != null:
		rarity = _rarity

	rarity = ITEM_RARITY.UNCOMMON
	if rarity == ITEM_RARITY.COMMON:
		var potion = potion_list[2].duplicate()
		potion.player = player
		potion._initialize()
		potion._ascend(player.item_power)
		var _item = potion_scene.instantiate()
		_item.i_name = potion.i_name
		_item.player = player
		_item.rarity = ITEM_RARITY.COMMON
		_item.im = self
		_item.charges = potion.charges
		_item.type = "Barrier"
		_item.add_child(potion)
		potion.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
		return _item
	elif rarity == ITEM_RARITY.UNCOMMON:
		var potion = potion_list[6].duplicate()
		potion.player = player
		potion._initialize()
		potion._ascend(player.item_power)
		var _item = potion_scene.instantiate()
		_item.i_name = potion.i_name
		_item.player = player
		_item.rarity = ITEM_RARITY.UNCOMMON
		_item.im = self
		_item.charges = potion.charges
		_item.type = "Barrier"
		_item.add_child(potion)
		potion.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
		return _item
	return null

func _create_stamina_potion(_rarity = null):
	var rarity = _calculate_item_rarity()
	if _rarity != null:
		rarity = _rarity

	rarity = ITEM_RARITY.UNCOMMON
	if rarity == ITEM_RARITY.COMMON:
		var potion = potion_list[3].duplicate()
		potion.player = player
		potion._initialize()
		potion._ascend(player.item_power)
		var _item = potion_scene.instantiate()
		_item.i_name = potion.i_name
		_item.player = player
		_item.rarity = ITEM_RARITY.COMMON
		_item.im = self
		_item.charges = potion.charges
		_item.type = "Stamina"
		_item.add_child(potion)
		potion.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
		return _item
	elif rarity == ITEM_RARITY.UNCOMMON:
		var potion = potion_list[7].duplicate()
		potion.player = player
		potion._initialize()
		potion._ascend(player.item_power)
		var _item = potion_scene.instantiate()
		_item.i_name = potion.i_name
		_item.player = player
		_item.rarity = ITEM_RARITY.UNCOMMON
		_item.im = self
		_item.charges = potion.charges
		_item.type = "Stamina"
		_item.add_child(potion)
		potion.set_owner(_item)
		_item._initialize()
		_item.picked_up.connect(player.get_node('InventoryManager')._on_potion_picked_up)
		return _item
	return null

func _drop_item(position):
	var _item = _create_item()
	if _item == null:
		return
	_item.global_position = position
	if self.get_children().find(_item) != -1:
		return

func _drop_bot_item(position):
	var _item = _create_item(ITEM_RARITY.COMMON)
	if _item == null:
		return
	_item.global_position = position
	if self.get_children().find(_item) != -1:
		return

func _drop_potion(position, type):
	var _potion
	if type == "Mana":
		_potion = _create_mana_potion()
	elif type == "Health":
		_potion = _create_health_potion()
	elif type == "Barrier":
		_potion = _create_barrier_potion()
	elif type == "Stamina":
		_potion = _create_stamina_potion()
	add_child(_potion)
	_potion.global_position = position
	if self.get_children().find(_potion) != -1:
		return

func _add_potion_to_inventory(type):
	var _potion
	if type == "Mana":
		_potion = _create_mana_potion(ITEM_RARITY.COMMON)
	else:
		_potion = _create_health_potion(ITEM_RARITY.COMMON)
	player.get_node('InventoryManager').add_child(_potion)
	player.get_node('InventoryManager')._on_potion_picked_up(_potion)

func _add_to_inventory():
	var _item
	if starting_items == 0:
		_item = _create_chest()
		starting_items += 1
	elif starting_items == 1:
		_item = _create_legs()
		starting_items += 1
	elif starting_items == 2:
		_item = _create_boots()
		starting_items += 1
	elif starting_items == 3:
		_item = _create_weapon()
		starting_items += 1
	if _item == null:
		return
	player.get_node('InventoryManager')._on_item_picked_up(_item)

func _add_specific_to_inventory(item_id):
	var _component = bot_list[item_id].duplicate()
	_component._initialize()
	var _item = item.instantiate()
	_item.i_name = _component.name
	_item.player = player
	_item.rarity = ITEM_RARITY.COMMON
	_item.im = self
	_item.add_child(_component)
	_component.set_owner(_item)
	_item._initialize()
	_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
	player.get_node('InventoryManager').get_node('Items').add_child(_item)
	player.get_node('InventoryManager')._on_item_picked_up(_item)

func _create_chest():
	var chest = bot_list[2].duplicate()
	chest._initialize()
	var _item = item.instantiate()
	_item.i_name = chest.name
	_item.player = player
	_item.rarity = ITEM_RARITY.COMMON
	_item.im = self
	_item.add_child(chest)
	_item._initialize()
	_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
	player.get_node('InventoryManager').get_node('Items').add_child(_item)
	return _item

func _create_legs():
	var legs = bot_list[4].duplicate()
	legs._initialize()
	var _item = item.instantiate()
	_item.i_name = legs.name
	_item.player = player
	_item.rarity = ITEM_RARITY.COMMON
	_item.im = self
	_item.add_child(legs)
	_item._initialize()
	_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
	player.get_node('InventoryManager').get_node('Items').add_child(_item)
	return _item

func _create_boots():
	var boots = bot_list[0].duplicate()
	boots._initialize()
	var _item = item.instantiate()
	_item.i_name = boots.name
	_item.player = player
	_item.rarity = ITEM_RARITY.COMMON
	_item.im = self
	_item.add_child(boots)
	_item._initialize()
	_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
	player.get_node('InventoryManager').get_node('Items').add_child(_item)
	return _item

func _create_weapon():
	var weapon = bot_list[weapon_list.pick_random()].duplicate()
	weapon._initialize()
	var _item = item.instantiate()
	_item.i_name = weapon.name
	_item.player = player
	_item.rarity = ITEM_RARITY.COMMON
	_item.im = self
	_item.add_child(weapon)
	_item._initialize()
	_item.picked_up.connect(player.get_node('InventoryManager')._on_item_picked_up)
	player.get_node('InventoryManager').get_node('Items').add_child(_item)
	return _item

func _on_character_manager_character_selected(unit):
	player = unit
