extends Node
@export var bot : PackedScene
@export var second_mid : PackedScene
@export var mid : PackedScene
@export var top : PackedScene
@export var item : PackedScene

var player = null

var bot_list
var second_mid_list
var mid_list
var top_list
var second_top_list
var unique_list

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
var weapon_list = [14, 15, 16, 17, 18, 19, 20]
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
	bot_instance.global_position = Vector2(-10000, -10000)
	second_mid.global_position = Vector2(-10000, -10000)
	mid_instance.global_position = Vector2(-10000, -10000)
	top_instance.global_position = Vector2(-10000, -10000)
	second_top.global_position = Vector2(-10000, -10000)

	_add_potion_to_inventory("Mana")
	_add_potion_to_inventory("Health")
	player.get_node('InventoryManager').current_potion_charges[0] = player.get_node('InventoryManager').potion_charges[0]
	player.get_node('InventoryManager').current_potion_charges[1] = player.get_node('InventoryManager').potion_charges[1]

	if !GameManager.is_save_file:
		for i in range(0, 4):
			_add_to_inventory()


func _calculate_item_rarity():
	randomize()
	var _randi = randi() % 100
	if _randi < 60:
		return
		
	print_debug("changed rarity")
	var rarity = 37.2 * player.item_drop_chance_multiplier
	if rarity < 30 * player.item_drop_chance_multiplier:
		return ITEM_RARITY.COMMON
	elif rarity < 35 * player.item_drop_chance_multiplier:
		return ITEM_RARITY.UNCOMMON
	elif rarity < 37 * player.item_drop_chance_multiplier:
		return ITEM_RARITY.RARE
	elif rarity < 37.3 * player.item_drop_chance_multiplier:
		return ITEM_RARITY.EPIC
	elif rarity < 37.5 * player.item_drop_chance_multiplier:
		return ITEM_RARITY.UNIQUE

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
		bot_piece._ascend(player.power)
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
		second_mid_piece._ascend(player.power)
		bot_piece._ascend(player.power)
		mid_piece._ascend(player.power)
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
		second_mid_piece._ascend(player.power)
		bot_piece._ascend(player.power)
		mid_piece._ascend(player.power)
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
		second_mid_piece._ascend(player.power)
		bot_piece._ascend(player.power)
		mid_piece._ascend(player.power)
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

		var bot_piece
		if unique_piece.unique_type == "Weapon":
			bot_piece = bot_list[weapon_list.pick_random()].duplicate()
		bot_piece._initialize()

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
	else:
		return null

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
		second_mid_piece._initialize()
		for i in range(second_mid_piece_data["values"].size()):
			second_mid_piece.set(second_mid_piece_data["tags"][i], second_mid_piece_data["values"][i])
		second_mid_piece.set_owner(item_)
		item_.add_child(second_mid_piece)
	if mid_piece_data != null:
		var mid_piece_index = _find_item_in_list(mid_piece_data["name"], mid_list)
		mid_piece = mid_list[mid_piece_index].duplicate()
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

func _find_item_in_list(item_name, list):
	for i in range(list.size()):
		if list[i].name == item_name:
			return i
	return -1

func _create_health_potion():
	var potion = potion_list[0].duplicate()
	potion._initialize()
	return potion

func _create_mana_potion():
	var potion = potion_list[1].duplicate()
	potion._initialize()
	return potion

func _drop_item(position):
	var _item = _create_item()
	if _item == null:
		return
	_item.global_position = position
	if self.get_children().find(_item) != -1:
		return
	_item._play_random_animation()

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
	else:
		_potion = _create_health_potion()
	_potion.global_position = position

func _add_potion_to_inventory(type):
	var _potion
	if type == "Mana":
		_potion = _create_mana_potion()
	else:
		_potion = _create_health_potion()
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
