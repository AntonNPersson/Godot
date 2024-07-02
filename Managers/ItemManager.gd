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

var starting_items = 0
var weapon_list = [14, 15, 16, 17, 18, 19, 20]
var potion_list

const ITEM_RARITY = {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	EPIC = 3
}

# Called when the node enters the scene tree for the first time. vres://Items/Mid Effects/Mid effects list.tscn
func _ready():
	var bot_instance = bot.instantiate()
	var mid_instance = preload('res://Items/Low-Mid Effects/lowmidlist.tscn').instantiate()
	var second_mid = preload('res://Items/Low-Mid Effects/lowmidlist2.tscn').instantiate()
	var top_instance = preload('res://Items/Mid Effects/Mid effects list.tscn').instantiate()
	var second_top = preload('res://Items/Top Effects/top list effects.tscn').instantiate()
	var potion_instance = preload('res://Items/Potions/potion list.tscn').instantiate()

	bot_list = bot_instance.get_children()
	second_mid_list = second_mid.get_children()
	mid_list = mid_instance.get_children()
	top_list = top_instance.get_children()
	second_top_list = second_top.get_children()
	potion_list = potion_instance.get_children()


	get_node('Items').add_child(bot_instance)
	get_node('Items').add_child(second_mid)
	get_node('Items').add_child(mid_instance)
	get_node('Items').add_child(top_instance)
	get_node('Items').add_child(second_top)
	get_node('Items').add_child(potion_instance)
	bot_instance.global_position = Vector2(-10000, -10000)
	second_mid.global_position = Vector2(-10000, -10000)
	mid_instance.global_position = Vector2(-10000, -10000)
	top_instance.global_position = Vector2(-10000, -10000)
	second_top.global_position = Vector2(-10000, -10000)

	_add_potion_to_inventory("Mana")
	_add_potion_to_inventory("Health")
	player.get_node('InventoryManager').current_potion_charges[0] = player.get_node('InventoryManager').potion_charges[0]
	player.get_node('InventoryManager').current_potion_charges[1] = player.get_node('InventoryManager').potion_charges[1]
	for i in range(0, 4):
		_add_to_inventory()


func _calculate_item_rarity():
	var _randi = randi() % 100
	if _randi < 60:
		return

	var rarity = 53
	if rarity < 30:
		return ITEM_RARITY.COMMON
	elif rarity < 45:
		return ITEM_RARITY.UNCOMMON
	elif rarity < 52:
		return ITEM_RARITY.RARE
	elif rarity < 54:
		return ITEM_RARITY.EPIC
	else:
		return null

func _create_item(_rarity = null):
	var rarity = _calculate_item_rarity()
	if _rarity != null:
		rarity = _rarity
	if rarity == ITEM_RARITY.COMMON:
		var bot_piece = bot_list[randi() % bot_list.size()].duplicate()
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
		var second_mid_piece = second_mid_list[randi() % second_mid_list.size()].duplicate()
		second_mid_piece._initialize()
		bot_piece._initialize()
		var mid_piece = mid_list[randi() % mid_list.size()].duplicate()
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
		var second_mid_piece = second_mid_list[randi() % second_mid_list.size()].duplicate()
		var mid_piece = mid_list[randi() % mid_list.size()].duplicate()
		var top_piece = top_list[randi() % top_list.size()].duplicate()
		second_mid_piece._initialize()
		bot_piece._initialize()
		mid_piece._initialize()
		top_piece._initialize()
		second_mid_piece._ascend(player.power)
		bot_piece._ascend(player.power)
		mid_piece._ascend(player.power)
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
		var second_mid_piece = second_mid_list[randi() % second_mid_list.size()].duplicate()
		var mid_piece = mid_list[randi() % mid_list.size()].duplicate()
		var top_piece = top_list[randi() % top_list.size()].duplicate()
		var second_top_piece = second_top_list[randi() % second_top_list.size()].duplicate()
		second_mid_piece._initialize()
		bot_piece._initialize()
		mid_piece._initialize()
		top_piece._initialize()
		second_top_piece._initialize()
		second_mid_piece._ascend(player.power)
		bot_piece._ascend(player.power)
		mid_piece._ascend(player.power)
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
	else:
		return null

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
	if self.get_children().find(_potion) != -1:
		return

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
