extends Node
signal add_stats(value)
signal remove_stats(value)
signal item_selected(item)
var tooltip
var unique_items = []
var legendary_items = []
var items : Array
var inventory : Array
var storage : Array
var potions : Array
var abilities : Array
var enchants : Array
var abilities_targeting = [false,false,false,false]
var potion_charges : Array
var current_potion_charges = [0,0]
var cooldown_timers : Array[float]
var ability_charges : Array[float]
var container_hud
var potion_hud
var health_bar
var barrier_bar
var mana_bar
var stamina_bar
var base_stat_list
var offensive_stat_list
var defensive_stat_list
var utility_stat_list
var global_stat_list
var character_specific_list
var inventory_hud
@export var simple_tooltip : PackedScene
var hotbar
var potion_bar_1
var potion_bar_2
var level_bar
var unit
var selected_item
var selected_storage_item
var selected_potion
var selected_icon
var movement
var weapon_equipped = false
var current_weapon = null
var PROJECTILE_TYPE = {
	'Passive' : 4,
	'EnemyTarget' : 1,
	'AllyTarget' : 2,
	'Self' : 5,
	'Summon' : 9
}
var ability_mapping = {
	"Ability_1": 0,
	"Ability_2": 1,
	"Ability_3": 2,
	"Ability_4": 3
}

@onready var max_potion_slots = 2
@onready var max_slots = 6
@onready var max_storage_slots = 18

var equipment_slots
var potion_slots
var storage_slots
var statistics
var items_
var _dragging = false
var _drag_offset = Vector2()

var cooldown_timer_multiple = 1

func _ready():
	unit = get_parent()
	inventory_hud = get_node("CanvasLayer/Inventory")
	container_hud = get_node("CanvasLayer/Inventory/PanelContainer2")
	potion_hud = container_hud.get_node("Equipment/potionList")
	potion_bar_1 = get_node("CanvasLayer/Bar_bag/Potion_1")
	potion_bar_2 = get_node("CanvasLayer/Bar_bag/Potion_2")
	level_bar = get_node('CanvasLayer/Bar_bag/level_bar')
	hotbar = get_node("CanvasLayer/HotbarC/Hotbar")
	health_bar = get_node('CanvasLayer/Bar_bag/ProgressBar5')
	barrier_bar = get_node('CanvasLayer/Bar_bag/ProgressBar2')
	mana_bar = get_node('CanvasLayer/Bar_bag/ProgressBar3')
	stamina_bar = get_node('CanvasLayer/Bar_bag/ProgressBar4')
	equipment_slots = container_hud.get_node("Items/Panel/VBoxContainer/Equipped")
	potion_slots = container_hud.get_node("Items/Panel/VBoxContainer/Potion")
	storage_slots = container_hud.get_node("Items/Panel/VBoxContainer/Storaged")	
	statistics = container_hud.get_node("Stats")
	items_ = container_hud.get_node("Items")
	base_stat_list = inventory_hud.get_node('Panel/ScrollContainer/VBoxContainer/Main')
	offensive_stat_list = inventory_hud.get_node('Panel/ScrollContainer/VBoxContainer/Offensive')
	defensive_stat_list = inventory_hud.get_node('Panel/ScrollContainer/VBoxContainer/Defensive')
	utility_stat_list = inventory_hud.get_node('Panel/ScrollContainer/VBoxContainer/Utility')
	global_stat_list = inventory_hud.get_node('Panel/ScrollContainer/VBoxContainer/Global')
	character_specific_list = inventory_hud.get_node('Panel/ScrollContainer/VBoxContainer/Extra')
	tooltip = simple_tooltip.instantiate()
	get_tree().get_root().add_child(tooltip)

func _process(delta):
	if current_weapon != null:
		current_weapon._use_weapon(unit, delta)
	_update_inventory_test()
	_update_stats()
	if potions.size() > 0:
		potion_bar_1._update_potion(potion_charges[0], current_potion_charges[0], potions[0].type)
	if potions.size() > 1:
		potion_bar_2._update_potion(potion_charges[1], current_potion_charges[1], potions[1].type)
	level_bar.get_node('level').text = '[center]' + str(unit.player_level)
	for i in abilities.size():
		cooldown_timers[i] -= cooldown_timer_multiple * delta
		hotbar.get_child(i).texture = abilities[i].icon
		hotbar.get_child(i).get_child(0).text ="[center][color=wheat]" + str(int(cooldown_timers[i]))
		if abilities[i].charges > 1:
			hotbar.get_child(i).get_child(2).visible = true
			hotbar.get_child(i).get_child(2).text = "[center][color=wheat]" + str(int(ability_charges[i]))
		else:
			hotbar.get_child(i).get_child(2).visible = false
		if cooldown_timers[i] <= 0:
			hotbar.get_child(i).get_child(0).visible = false
			if ability_charges[i] < abilities[i].charges:
				ability_charges[i] += 1
				if ability_charges[i] < abilities[i].charges:
					cooldown_timers[i] = abilities[i].cooldown
		else:
			hotbar.get_child(i).get_child(0).visible = true
		abilities[i]._update_targeting(delta,abilities_targeting, abilities_targeting[i])
	hotbar.get_node('TextureRect4').texture = unit.active_icon

	hotbar.get_node('TextureRect9').texture = unit.passive_icon

	if !hotbar.get_node('TextureRect8').is_connected('mouse_entered', _on_hotbar_character_mouse_entered):
		hotbar.get_node('TextureRect8').mouse_entered.connect(_on_hotbar_character_mouse_entered.bind(0))
		hotbar.get_node('TextureRect10').mouse_entered.connect(_on_hotbar_character_mouse_entered.bind(1))
	
	_handle_level_up_visability()

	if _dragging:
		var mouse_pos = container_hud.get_global_mouse_position()
		container_hud.global_position = mouse_pos - _drag_offset


func _clean_up_inventory():
	unique_items.clear()
	legendary_items.clear()
	for i in inventory.size():
		for j in inventory[i].get_children():
			if "unique" in j:
				if !unique_items.has(j.name):
					unique_items.append(j.name)
			elif "legendary" in j:
				legendary_items.append(j.name)

		

func _input(event):
	if event.is_action_released("Inventory"):
		toggle_hud('Inventory')
	elif event.is_action_released('Stats'):
		toggle_hud('Stats')
	elif event.is_action_released('Abilities'):
		toggle_hud('Abilities')

	if GameManager.settings['roguelike_controls']:
		if !event.is_echo():
			if event.is_action_pressed("Ability_1") and not event.is_action_pressed("Level_up_1"):
				activate_ability(0)
			elif event.is_action_pressed('Ability_2') and not event.is_action_pressed("Level_up_2"):
				activate_ability(1)
			elif event.is_action_pressed('Ability_3') and not event.is_action_pressed("Level_up_3"):
				activate_ability(2)

			if event.is_action_pressed('Level_up_1'):
				_on_level_pressed(0)
			elif event.is_action_pressed('Level_up_2'):
				_on_level_pressed(1)
			elif event.is_action_pressed('Level_up_3'):
				_on_level_pressed(2)

		if event.is_action_released("Ability_1") and !event.is_echo():
			if abilities.size() > 0 and abilities[0].is_channel_ability:
				abilities[0]._stop_channel()
		elif event.is_action_released('Ability_2') and !event.is_echo():
			if abilities.size() > 1 and abilities[1].is_channel_ability:
				abilities[1]._stop_channel()
		elif event.is_action_released('Ability_3') and !event.is_echo():
			if abilities.size() > 2 and abilities[2].is_channel_ability:
				abilities[2]._stop_channel()

		if event.is_action_pressed('Ability_Q') and !event.is_echo():
			if potions.size() > 0:
				if current_potion_charges[0] <= 0:
					Utility.get_node('ErrorMessage')._create_error_message('Potion has no charges left.', self)
					return
				potions[0].get_child(2)._use()
				current_potion_charges[0] -= 1
				_update_inventory_test()
		elif event.is_action_pressed('Ability_E') and !event.is_echo():
				if potions.size() > 1:
					if current_potion_charges[1] <= 0:
						Utility.get_node('ErrorMessage')._create_error_message('Potion has no charges left.', self)
						return
					potions[1].get_child(2)._use()
					current_potion_charges[1] -= 1
					_update_inventory_test()

		if event.is_action_released("Move"):
			if current_weapon != null and !unit.lose_camera_focus:
				current_weapon._initialize_weapon(unit)
		if event.is_action_pressed("Move"):
			if current_weapon != null and !unit.lose_camera_focus:
				current_weapon._pre_initialize_weapon(unit)

	elif GameManager.settings['moba_controls']:
		if event.is_action_pressed("Ability_Q") and !event.is_echo():
			activate_ability(0)
		elif event.is_action_pressed('Ability_W') and !event.is_echo():
			activate_ability(1)
		elif event.is_action_pressed('Ability_E') and !event.is_echo():
			activate_ability(2)

		if event.is_action_pressed('potion_1') and !event.is_echo():
			if potions.size() > 0:
				if current_potion_charges[0] <= 0:
					Utility.get_node('ErrorMessage')._create_error_message('Potion has no charges left.', self)
					return
				potions[0]._use()
				current_potion_charges[0] -= 1
				_update_inventory_test()
		elif event.is_action_pressed('potion_2') and !event.is_echo():
				if potions.size() > 1:
					if current_potion_charges[1] <= 0:
						Utility.get_node('ErrorMessage')._create_error_message('Potion has no charges left.', self)
						return
					potions[1]._use()
					current_potion_charges[1] -= 1
					_update_inventory_test()

	if abilities_targeting[0]:
		handle_targeting_input(event, abilities[0], 0)
	elif abilities_targeting[1]:
		handle_targeting_input(event, abilities[1], 1)
	elif abilities_targeting[2]:
		handle_targeting_input(event, abilities[2], 2)
	elif abilities_targeting[3]:
		handle_targeting_input(event, abilities[3], 3)

func _reduce_cooldown(_ability, amount):
	var index = abilities.find(_ability)
	cooldown_timers[index] -= amount

func _reset_cooldown(_ability):
	var index = abilities.find(_ability)
	cooldown_timers[index] = 0

func toggle_hud(hud):
	if hud == "Inventory":
		_update_inventory_test()
		if container_hud.get_parent().visible:
			container_hud.get_parent().visible = false
			items_.visible = false
			statistics.visible = false
		else:
			container_hud.get_parent().visible = true
			items_.visible = true
			statistics.visible = false
	elif hud == "Stats":
		_update_stats()
		if container_hud.get_parent().visible:
			container_hud.get_parent().visible = false
			items_.visible = false
			statistics.visible = false
		else:
			container_hud.get_parent().visible = true
			items_.visible = false
			statistics.visible = true

func _get_highest_power_ability():
	var highest_power = 0
	var highest_power_index = 0
	for i in range(abilities.size()):
		if abilities[i]._calculate_power() > highest_power:
			highest_power = abilities[i]._calculate_power()
			highest_power_index = i
	return highest_power

func activate_ability(index):
	if abilities.size() > index:
		unit.in_stealth = false

		if abilities[index].projectile_type == PROJECTILE_TYPE.Summon and cooldown_timers[index] > 0:
			if unit.get_node("Summons").get_child_count() > 0:
				for child in unit.get_node("Summons").get_children():
					child.global_position = unit.global_position
				return

		if unit.current_mana < abilities[index].mana_cost or unit.current_mana < unit.total_mana*(abilities[index].mana_cost_percentage/100) and abilities[index].projectile_type != PROJECTILE_TYPE.Passive:
			Utility.get_node('ErrorMessage')._create_error_message('Not enough mana', self)
			return

		if cooldown_timers[index] > 0 and abilities[index].projectile_type != PROJECTILE_TYPE.Passive and ability_charges[index] < 1:
			Utility.get_node('ErrorMessage')._create_error_message('Ability on cooldown', self)
			return

		if abilities[index].projectile_type == PROJECTILE_TYPE.Passive:
			abilities[index]._use()
			return

		if abilities[index].area_channel or abilities[index].projectile_channel:
			abilities[index]._start_channel()
			return

		if abilities[index].projectile_type == PROJECTILE_TYPE.Self or abilities[index].projectile_type == PROJECTILE_TYPE.Summon or GameManager.settings['smart_cast']:
			abilities[index]._use()
			if unit._apply_double_cast_chance():
				await get_tree().create_timer(0.1).timeout
				abilities[index]._use()
			cooldown_timers[index] = unit._apply_cooldown_reduction(abilities[index].cooldown)
			ability_charges[index] -= 1
		else:
			abilities_targeting[index] = true

func handle_targeting_input(event, ab, index):
	if event.is_action_pressed("Attack"):
		if ab.projectile_type == PROJECTILE_TYPE.Self or ab.projectile_type == PROJECTILE_TYPE.Summon:
			return
		ab.unit = unit
		var in_range
		if ab.projectile_type == PROJECTILE_TYPE.EnemyTarget or ab.projectile_type == PROJECTILE_TYPE.AllyTarget:
			in_range = ab._use()
			if unit._apply_double_cast_chance():
				await get_tree().create_timer(0.1).timeout
				ab._use()
		else:
			ab._use()
			in_range = true

		if in_range:
			cooldown_timers[index] = unit._apply_cooldown_reduction(ab.cooldown)
			ability_charges[index] -= 1
		abilities_targeting[index] = false
		Utility.get_node('AbilityTargetSystem')._erase_targeting()
	elif event.is_action_pressed("Move"):
		Utility.get_node('AbilityTargetSystem')._erase_targeting()
		abilities_targeting[index] = false

func _update_inventory_test():
	_update_stats()
	for item in inventory:
		if !is_instance_valid(item):
			continue
	for i in equipment_slots.get_child_count():
		equipment_slots.get_child(i).get_node('Icon').texture = null
		equipment_slots.get_child(i).get_node('Icon').visible = false
		equipment_slots.get_child(i).get_node('Icon_border').visible = false

	for i in potion_slots.get_child_count():
		potion_slots.get_child(i).get_node('Icon').texture = null
		potion_slots.get_child(i).get_node('Icon').visible = false
		potion_slots.get_child(i).get_node('Icon_border').visible = false

	for i in storage_slots.get_child_count():
		storage_slots.get_child(i).get_node('Icon').texture = null
		storage_slots.get_child(i).get_node('Icon').visible = false
		storage_slots.get_child(i).get_node('Icon_border').visible = false

	for i in inventory.size():
		equipment_slots.get_child(i).get_node('Icon').texture = load(inventory[i].get_child(2).icon.resource_path)
		equipment_slots.get_child(i).get_node('Icon').visible = true
		equipment_slots.get_child(i).get_node('Icon_border').modulate = inventory[i].rarity_color
		equipment_slots.get_child(i).get_node('Icon_border').visible = true

	for i in potions.size():
		potion_slots.get_child(i).get_node('Icon').texture = load(potions[i].get_child(2).icon.resource_path)
		potion_slots.get_child(i).get_node('Icon').visible = true
		potion_slots.get_child(i).get_node("Icon_border").modulate = potions[i].rarity_color
		potion_slots.get_child(i).get_node('Icon_border').visible = true

	for i in storage.size():
		storage_slots.get_child(i).get_node('Icon').texture = load(storage[i].get_child(2).icon.resource_path)
		storage_slots.get_child(i).get_node('Icon').visible = true
		storage_slots.get_child(i).get_node('Icon_border').modulate = storage[i].rarity_color
		storage_slots.get_child(i).get_node('Icon_border').visible = true


func _update_stats():

	var base_stats = {
		"Health": {"base": int(unit.base_health), "bonus": (unit.bonus_health + (unit.total_vitality * 0.5)) * (1 + unit.global_health/100), "tooltip" : "Health is the amount of damage a unit can take before dying."},
		"Mana": {"base": int(unit.base_mana), "bonus": (unit.bonus_mana + (unit.total_intelligence * 2)) * (1 + unit.global_mana/100), "tooltip" : "Mana is the resource used to cast most abilities."},
		"Stamina": {"base": int(unit.base_stamina), "bonus": (unit.bonus_stamina + (unit.total_strength/10)) * (1 + unit.global_stamina/100), "tooltip" : "Stamina is the resource used to perform each units unique active ability."},
		"Barrier": {"base": int(unit.base_barrier), "bonus": unit.bonus_barrier * (1 + unit.global_barrier/100), "tooltip" : "Barrier is a temporary shield that absorbs damage before health."},
		"Dexterity": {"base": int(unit.base_dexterity), "bonus": unit.bonus_dexterity * (1 + unit.global_dexterity/100), "tooltip" : "Dexterity increases the damage of dex based spells, as well as increasing total movement speed."},
		"Strength": {"base": int(unit.base_strength), "bonus": unit.bonus_strength * (1 + unit.global_strength/100), "tooltip" : "Strength increases the damage of str based spells, as well as increasing total stamina."},
		"Intelligence": {"base": int(unit.base_intelligence), "bonus": unit.bonus_intelligence * (1 + unit.global_intelligence/100), "tooltip" : "Intelligence increases the damage of int based spells, as well as increasing total mana."},
	}

	var offensive_stats = {
		"Attack Damage": {"base": int(unit.base_attack_damage), "bonus": unit.bonus_attack_damage * (1 + (unit.global_attack_damage/100 + unit.global_damage/100)), "tooltip" : "Attack Damage increases the damage of auto attacks, and certain spells."},
		"Attack Speed": {"base": round_place(unit.base_attack_speed,2), "bonus": unit.bonus_attack_speed, "tooltip" : "Attack Speed increases the rate at which a unit can auto attack, reducing total windup time."},
		"Critical Strike Chance": {"base": round_place(unit.base_critical_chance,2), "bonus": unit.bonus_critical_chance, "tooltip" : "Critical Strike Chance increases the chance of landing a critical strike."},
		"Critical Strike Damage": {"base": int(unit.base_critical_damage), "bonus": unit.bonus_critical_damage, "tooltip" : "Critical Strike Damage increases the damage of critical strikes."},
		"Cooldown Reduction": {"base": int(unit.base_cooldown_reduction), "bonus": unit.bonus_cooldown_reduction, "tooltip" : "Cooldown Reduction decreases the cooldown of abilities."},
		"Quick Attack Chance": {"base": round_place(unit.base_quick_attack_chance,2), "bonus": unit.bonus_quick_attack_chance, "tooltip" : "Quick Attack Chance increases the chance of auto attacking twice, everytime values exceed the 100% mark theres a chance for an additional attack."},
		"Double Cast Chance": {"base": round_place(unit.base_double_cast_chance,2), "bonus": unit.bonus_double_cast_chance, "tooltip" : "Double Cast Chance increases the chance of casting an ability twice, everytime values exceed the 100% mark theres a chance for an additional cast."},
	}

	var defensive_stats = {
		"Armor": {"base": int(unit.base_armor), "bonus": unit.bonus_armor * (1 + unit.global_armor/100), "tooltip" : "Armor reduces a percentage of the amount of direct damage taken."},
		"Evade": {"base": int(unit.base_evade), "bonus": unit.bonus_evade * (1 + unit.global_evade/100), "tooltip" : "Evade increases the chance of dodging an attack, nullifying the damage - works on all direct damage sources."},
		"Vitality": {"base": int(unit.base_vitality), "bonus": unit.bonus_vitality * (1 + unit.global_vitality/100), "tooltip" : "Vitality increases the total health and health regen of a unit."},
		"Slow Resistance": {"base": round_place(unit.base_slow_resistance,2), "bonus": unit.bonus_slow_resistance, "tooltip" : "Slow Resistance decreases the duration of slow effects."},
		"Affliction Resistance": {"base": round_place(unit.base_affliction_resistance,2), "bonus": unit.bonus_affliction_resistance, "tooltip" : "Affliction Resistance decreases the duration of DOT effects."},
		"Crowd Control Resistance": {"base": round_place(unit.base_crowd_control_resistance,2), "bonus": unit.bonus_crowd_control_resistance, "tooltip": "Crowd Control Resistance decreases the duration of CC effects."},
		"Block": {"base": round_place(unit.base_block,2), "bonus": unit.bonus_block, "tooltip" : "Block reduces a flat amount of direct damage taken."},
		"Lifesteal": {"base": round_place(unit.base_life_steal,2), "bonus": unit.bonus_life_steal, "tooltip" : "Lifesteal heals the unit for a percentage of the auto attack damage dealt."},
		"Spell Vamp": {"base": round_place(unit.base_spell_vamp,2), "bonus": unit.bonus_spell_vamp, "tooltip" : "Spell Vamp heals the unit for a percentage of the spell damage dealt."},
		"Thorns": {"base": round_place(unit.base_thorns,2), "bonus": unit.bonus_thorns, "tooltip" : "Thorns deals its value divided by ten as damage back to the attacker."},
	}

	var utility_stats = {
		"Movement Speed": {"base": round_place(unit.base_speed,2), "bonus": unit.bonus_speed, "tooltip" : "Movement Speed increases the rate at which a unit can move."},
		"Attack Range": {"base": round_place(unit.base_range,2), "bonus": unit.bonus_range, "tooltip" : "Attack Range increases the distance at which a unit can auto attack, less than 60 is considered melee."},
		"Frozen Chance": {"base": round_place(unit.base_frozen_chance,2), "bonus": unit.bonus_frozen_chance, "tooltip" : "Frozen Chance increases the chance of causing frozen effect."},
		"Windup Time": {"base": round_place(unit.total_windup_time,2), "bonus": 0, "tooltip" : "Windup Time increases the time it takes to perform an auto attack, reduced by attack speed."},
		"Health Regen": {"base": round_place(unit.base_health_regen,1), "bonus": (unit.bonus_health_regen + (unit.total_vitality * 0.05)) * (1 + unit.global_health_regen/100), "tooltip" : "Health Regen increases the amount of health regenerated per second."},
		"Mana Regen": {"base": round_place(unit.base_mana_regen,1), "bonus": unit.bonus_mana_regen * (1 + unit.global_mana_regen/100), "tooltip" : "Mana Regen increases the amount of mana regenerated per second."},
		"Stamina Regen": {"base": round_place(unit.base_stamina_regen,1), "bonus": unit.bonus_stamina_regen * (1 + unit.global_stamina_regen/100), "tooltip" : "Stamina Regen increases the amount of stamina regenerated per second."},
		"Barrier Regen": {"base": round_place(unit.base_barrier_regen,1), "bonus": unit.bonus_barrier_regen * (1 + unit.global_barrier_regen/100), "tooltip" : "Barrier Regen increases the amount of barrier regenerated per second."},
		"Item Drop Chance": {"base": (unit.item_drop_chance_multiplier - 1) * 100, "bonus": 0, "tooltip" : "Item Drop Chance increases the chance of dropping items."},
		"Ascension Currency Multiplier": {"base": (unit.ascension_currency_multiplier - 1) * 100, "bonus": 0, "tooltip" : "Ascension Currency Multiplier increases the amount of ascension currency dropped."},
		"Experience Multiplier": {"base": (unit.experience_multiplier - 1) * 100, "bonus": 0, "tooltip" : "Experience Multiplier increases the amount of experience gained."},
		"Ascension Level": {"base": unit.ascension_level, "bonus": 0, "tooltip" : "Ascension Level increases the difficulty of the game, and the amount of ascension currency dropped."},
		"Ascension Currency": {"base": unit.ascension_currency, "bonus": 0, "tooltip" : "Ascension Currency is used to purchase different upgrades."},
		"Rerolls": {"base": unit.rerolls, "bonus": 0, "tooltip" : "Rerolls are used to reroll spells, enchants and curses."},
	}

	var global_stats = {
		"Burn Damage": {"base": unit.global_burn_damage, "tooltip" : "Global Burn Damage increases all the damage of burns by a percentage - burn has a base duration of 5 seconds with a 1 second tick rate. \n\nBurn effects apply seperately and can't stack."},
		"Bleed Damage": {"base": unit.global_bleed_damage, "tooltip" : "Global Bleed Damage increases all the damage of bleeds by a percentage - bleed has a duration of 2 seconds with a 0.5 second tick rate. \n\nIf new sources of bleed are applied the duration only refreshes if the new source has a higher damage, else it adds a stack increasing the damage by 50%."},
		"Poison Damage": {"base": unit.global_poison_damage, "tooltip" : "Global Poison Damage increases all the damage of poisons by a percentage, poison has a duration of 5 seconds and a base damage of 5, with a 1 second tick rate. \n\nPoison effects only apply stacks, each stack doing the base damage."},
		"Damage": {"base": unit.global_damage, "tooltip" : "Global Damage increases the damage of everything by a percentage."},
		"Attack Damage": {"base": unit.global_attack_damage, "tooltip" : "Global Attack Damage increases all the damage of auto attacks, and certain spells by a percentage."},
		"Freeze Efficiency": {"base": unit.global_freeze_effectiveness, "tooltip" : "Global Freeze Efficiency increases the amount slowed by frozen effects by a percentage."},
		"Heal Efficiency": {"base": unit.global_heal_effectiveness, "tooltip" : "Global Heal Efficiency increases all the amount healed by a percentage."},
		"Movement Speed": {"base": unit.global_movement_speed, "tooltip" : "Global Movement Speed increases all the flat amount of movement speed."},
		"Evade": {"base": unit.global_evade, "tooltip" : "Global Evade increases all the flat amount of evade."},
		"Armor": {"base": unit.global_armor, "tooltip" : "Global Armor increases all the flat amount of armor."},
		"Block": {"base": unit.global_block, "tooltip" : "Global Block increases all the flat amount of block."},
		"Thorns": {"base": unit.global_thorns, "tooltip" : "Global Thorns increases all the flat amount of damage thorns does."},
		"Health": {"base": unit.global_health, "tooltip" : "Global Health increases the total health of a unit by a percentage."},
		"Mana": {"base": unit.global_mana, "tooltip" : "Global Mana increases the total mana of a unit by a percentage."},
		"Stamina": {"base": unit.global_stamina, "tooltip" : "Global Stamina increases the total stamina of a unit by a percentage."},
		"Barrier": {"base": unit.global_barrier, "tooltip" : "Global Barrier increases the total barrier of a unit by a percentage."},
		"Dexterity": {"base": unit.global_dexterity, "tooltip" : "Global Dexterity increases all the flat dexterity."},
		"Strength": {"base": unit.global_strength, "tooltip" : "Global Strength increases all the flat strength."},
		"Intelligence": {"base": unit.global_intelligence, "tooltip" : "Global Intelligence increases all the flat intelligence."},
		"Vitality": {"base": unit.global_vitality, "tooltip" : "Global Vitality increases all the total health and health regen of a unit by a percentage."},
		"Health Regen": {"base": unit.global_health_regen, "tooltip" : "Global Health Regen increases all the amount of health regenerated per second by a percentage."},
		"Mana Regen": {"base": unit.global_mana_regen, "tooltip" : "Global Mana Regen increases all the flat amount of mana regenerated per second by a percentage."},
		"Stamina Regen": {"base": unit.global_stamina_regen, "tooltip" : "Global Stamina Regen increases all the flat amount of stamina regenerated per second by a percentage."},
		"Barrier Regen": {"base": unit.global_barrier_regen, "tooltip" : "Global Barrier Regen increases all the flat amount of barrier regenerated per second by a percentage."},
	}

	var character_specifics
	if unit.movement_skill != null:
		character_specifics = {
			"Movement Ability": {"base": unit.movement_skill.name, "bonus": unit.movement_skill.tooltip},
			"Passive Ability": {"base": unit.passive_name, "bonus": unit.passive_tooltip}
		}

	base_stat_list.clear()
	offensive_stat_list.clear()
	defensive_stat_list.clear()
	utility_stat_list.clear()
	global_stat_list.clear()
	character_specific_list.clear()
	var stat

	for s in base_stats:
		stat = base_stat_list.add_item(" " + s + ": " + str(int(base_stats[s].base + base_stats[s].bonus)), null, false)
		base_stat_list.set_item_tooltip(stat, 'Base: ' + str(base_stats[s].base) + ' Bonus: ' + str(int(base_stats[s].bonus)) + '\n\n' + str(base_stats[s].tooltip))

	for s in offensive_stats:
		if "Chance" in s or "Reduction" in s:
			stat = offensive_stat_list.add_item(" " + s + ": " + str(int(offensive_stats[s].base + offensive_stats[s].bonus)) + "%", null, false)
			offensive_stat_list.set_item_tooltip(stat, 'Base: ' + str(offensive_stats[s].base) + '% Bonus: ' + str(int(offensive_stats[s].bonus)) + '%' + '\n\n' + str(offensive_stats[s].tooltip))
		else:
			stat = offensive_stat_list.add_item(" " + s + ": " + str(int(offensive_stats[s].base + offensive_stats[s].bonus)), null, false)
			offensive_stat_list.set_item_tooltip(stat, 'Base: ' + str(offensive_stats[s].base) + ' Bonus: ' + str(int(offensive_stats[s].bonus)) + '\n\n' + str(offensive_stats[s].tooltip))

	for s in defensive_stats:
		if "Resistance" in s:
			stat = defensive_stat_list.add_item(" " + s + ": " + str(int(defensive_stats[s].base + defensive_stats[s].bonus)) + "%", null, false)
			defensive_stat_list.set_item_tooltip(stat, 'Base: ' + str(defensive_stats[s].base) + '% Bonus: ' + str(int(defensive_stats[s].bonus)) + '%' + '\n\n' + str(defensive_stats[s].tooltip))
		else:
			stat = defensive_stat_list.add_item(" " + s + ": " + str(int(defensive_stats[s].base + defensive_stats[s].bonus)), null, false)
			defensive_stat_list.set_item_tooltip(stat, 'Base: ' + str(defensive_stats[s].base) + ' Bonus: ' + str(int(defensive_stats[s].bonus)) + '\n\n' + str(defensive_stats[s].tooltip))

	for s in utility_stats:
		if "Chance" in s or "Multiplier" in s:
			stat = utility_stat_list.add_item(" " + s + ": " + str(int(utility_stats[s].base + utility_stats[s].bonus)) + "%", null, false)
			utility_stat_list.set_item_tooltip(stat, 'Base: ' + str(utility_stats[s].base) + '% Bonus: ' + str(int(utility_stats[s].bonus)) + '%' + '\n\n' + str(utility_stats[s].tooltip))
		else:
			stat = utility_stat_list.add_item(" " + s + ": " + str(int(utility_stats[s].base + utility_stats[s].bonus)), null, false)
			utility_stat_list.set_item_tooltip(stat, 'Base: ' + str(utility_stats[s].base) + ' Bonus: ' + str(int(utility_stats[s].bonus)) + '\n\n' + str(utility_stats[s].tooltip))

	for s in global_stats:
		stat = global_stat_list.add_item(" " + s + ": " + str(int(global_stats[s].base)) + "%", null, false)
		global_stat_list.set_item_tooltip(stat, str(global_stats[s].tooltip))

	if character_specifics != null:
		for s in character_specifics:
			stat = character_specific_list.add_item(" " + s + ": " + str(character_specifics[s].base), null, false)
			character_specific_list.set_item_tooltip(stat, character_specifics[s].bonus)

	health_bar._update_health(unit._calculate_percentage(unit.current_health, unit.total_health))
	health_bar.get_child(0).text = "[center][color=Wheat]" + str(int(unit.current_health)) + "/" + str(int(unit.total_health))
	barrier_bar._update_barrier(unit._calculate_percentage(unit.current_barrier, unit.total_barrier))
	mana_bar._update_mana(unit._calculate_percentage(unit.current_mana, unit.total_mana))
	mana_bar.get_child(0).text = "[center][color=Wheat]" + str(int(unit.current_mana)) + "/" + str(int(unit.total_mana))
	stamina_bar._update_stamina(unit._calculate_percentage(unit.current_stamina, unit.total_stamina))
	stamina_bar.get_child(0).text = "[center][color=Wheat]" + str(int(unit.current_stamina)) + "/" + str(int(unit.total_stamina))
	level_bar._update_exp(unit._calculate_percentage(unit.current_player_experience, unit.total_player_experience))

func round_place(num, places):
	return (round(num*pow(10,places))/pow(10,places))

func _on_ability_manager_picked(_ability, subwave):
	if abilities == null:
		abilities = Array()
	
	if abilities.size() >= 3:
		pass
	abilities.append(_ability)
	cooldown_timers.append(0)
	ability_charges.append(_ability.charges)

	_ability.unit = self.get_parent()
	_ability.is_docile = false
	_ability._initialize()
	add_child(_ability)

func _on_enchant_picked(enchant, index, _type):
	enchant._initialize()
	for i in range(enchant.tags.size()):
		abilities[index]._add_enchant(enchant.tags[i], enchant.values[i], enchant.types, enchant.extra, enchant)

func _add_item_effect(type, tag, value, duration, item_color, item_cooldown = 0):
	var extra = {
			"Duration" : duration,
			"Color" : item_color,
			"Cooldown" : item_cooldown
		}

	# I know it's redundant but it's for the sake of readability
	if type == 'OnCast':
		for a in abilities:
			if item_cooldown == null:
				item_cooldown = 0
			a._add_item_tag(tag, value, duration, item_color, item_cooldown)
	elif type == 'OnHit':
		unit.get_node('Control')._on_action(value, true, unit, tag, extra)
	elif type == 'OnBurn':
		unit.get_node('Control')._on_action(value, true, unit, tag, extra)
	elif type == 'OnFrozen':
		unit.get_node('Control')._on_action(value, true, unit, tag, extra)
	elif type == "OnPoison":
		unit.get_node('Control')._on_action(value, true, unit, tag, extra)
	elif type == "OnBleed":
		unit.get_node('Control')._on_action(value, true, unit, tag, extra)
	elif type == "OnEquip":
		unit.get_node('Control')._on_action(value, true, unit, tag, extra)
			

func _remove_item_effect(type, tag, value):
	var extra = {
		"Duration" : 0,
		"Color" : Color(0,0,0,0),
		"Cooldown" : 0
	}
	if type == 'OnCast':
		for a in abilities:
			a._remove_item_tag(tag)
	elif type == 'OnHit':
		unit.get_node('Control')._on_action(-value, false, unit, tag, extra)
	elif type == 'OnBurn':
		unit.get_node('Control')._on_action(-value, false, unit, tag, extra)
	elif type == 'OnFrozen':
		unit.get_node('Control')._on_action(-value, false, unit, tag, extra)
	elif type == "OnPoison":
		unit.get_node('Control')._on_action(-value, false, unit, tag, extra)
	elif type == "OnBleed":
		unit.get_node('Control')._on_action(-value, false, unit, tag, extra)
	elif type == "OnEquip":
		unit.get_node('Control')._on_action(-value, false, unit, tag, extra)

func _on_item_picked_up(item):
	var children_ = item.get_children()
	var unique_item = null
	var legendary_item = null
	# Clean from unique items and check if unique item is already equipped
	_clean_up_inventory()

	# Check if inventory is full
	if inventory.size() >= max_slots:
		if storage.size() < max_storage_slots:
			storage.append(item)
			_update_inventory_test()
			item.remove_from_group("Items")
		else:
			Utility.get_node("ErrorMessage")._create_error_message("Storage full", self)
		return

	# Check if item is unique or legendary
	for i in range(2, children_.size()):
		if "unique" in children_[i]:
			if unique_items.find(children_[i].name) != -1:
				Utility.get_node("ErrorMessage")._create_error_message("Unique item already equipped", self)
				if storage.size() <= max_storage_slots:
					storage.append(item)
					_update_inventory_test()
					return
				else:
					Utility.get_node("ErrorMessage")._create_error_message("Storage full", self)
					return
			unique_item = children_[i].name
			unique_items.append(children_[i].name)

		if "legendary" in children_[i]:
			if legendary_items.size() > 0:
				Utility.get_node("ErrorMessage")._create_error_message("Legendary item already equipped", self)
				if storage.size() <= max_storage_slots:
					storage.append(item)
					_update_inventory_test()
					return
				else:
					Utility.get_node("ErrorMessage")._create_error_message("Storage full", self)
					return
			legendary_items.append(children_[i].name)
			legendary_item = children_[i].name
	
	# Check if item is a weapon
	if "range" in children_[2]:
			if weapon_equipped:
				if storage.size() < max_storage_slots:
					storage.append(item)
					_update_inventory_test()
					if unique_item  != null:
						unique_items.remove_at(unique_items.find(unique_item))
					if legendary_item != null:
						legendary_items.remove_at(legendary_items.find(legendary_item))
				else:
					Utility.get_node("ErrorMessage")._create_error_message("Storage full", self)
				return
			if GameManager.selected_character_name == "Ranger":
				if children_[2].range < 75:
					Utility.get_node("ErrorMessage")._create_error_message("Can't equip melee weapon", self)
					return
			current_weapon = item.get_child(2)
			weapon_equipped = true

	# Add item to inventory
	inventory.append(item)
	_update_inventory_test()

	# Add stats from item
	var children = item.get_children()
	if children.size() > 2:
		for i in range(2, children.size()):
			# Check if item is an epic item, and add the effect
			if "epic" in children[i]:
				if "cooldown" in children[i]:
					_add_item_effect(children[i].epic, children[i].tags[0], children[i].values[0], children[i].duration, children[i].colors[0], children[i].cooldown)
					if "legendary" not in children[i]:
						continue
				else:
					_add_item_effect(children[i].epic, children[i].tags[0], children[i].values[0], children[i].duration, children[i].colors[0])
					if "legendary" not in children[i]:
						continue
			var added_stats = {}
			for j in range(children[i]._get_tags().size()):
				added_stats[children[i]._get_tags()[j]] = children[i]._get_values()[j]
			add_stats.emit(added_stats)
	_update_stats()
	item.remove_from_group("Items")

func _on_item_dropped(to_storage = false):
	if inventory.size() >= 0:
		if selected_item:
			var children = selected_item.get_children()
			if children.size() > 2:
				for i in range(2, children.size()):
					if "range" in children[i]:
						weapon_equipped = false
						current_weapon = null
					if "unique" in children[i]:
						unique_items.remove_at(unique_items.find(children[i].name))	
					if "legendary" in children[i]:
						legendary_items.remove_at(legendary_items.find(children[i].name))
					var removed_stats = {}
					if "epic" in children[i]:
						_remove_item_effect(children[i].epic, children[i].tags[0], children[i].values[0])
					for j in range(children[i]._get_tags().size()):
						removed_stats[children[i]._get_tags()[j]] = children[i]._get_values()[j]
					remove_stats.emit(removed_stats)
			inventory.erase(selected_item)
			_update_inventory_test()
			_update_stats()
			if !to_storage:
				selected_item._drop_item()
		else:
			print("No item selected")

func _on_storage_item_dropped(to_inventory = false):
	if storage.size() >= 0:
		if selected_storage_item:
			storage.erase(selected_storage_item)
			_update_inventory_test()
			if !to_inventory:
				selected_storage_item._drop_item()
		else:
			print("No item selected")

func _add_from_inventory_to_storage(it):
	selected_item = it
	if inventory.size() > 0:
		if storage.size() < max_storage_slots:
			_on_item_dropped(true)
			storage.append(it)
			_update_inventory_test()
			selected_item.get_child(0).get_child(0).visible = false
		else:
			Utility.get_node("ErrorMessage")._create_error_message("Storage full", self)

func _add_from_potions_to_storage(it):
	selected_potion = it
	if potions.size() > 0:
		if storage.size() < max_storage_slots:
			_on_potion_dropped(true)
			storage.append(it)
			_update_inventory_test()
			selected_potion.get_child(0).get_child(0).visible = false
		else:
			Utility.get_node("ErrorMessage")._create_error_message("Storage full", self)

func _add_from_storage_to_inventory(it):
	selected_storage_item = it
	# Check if item is unique, and if it's already equipped
	for i in range(2, selected_storage_item.get_children().size()):
		if "unique" in selected_storage_item.get_child(i):
			if selected_storage_item.get_child(i).name in unique_items:
				Utility.get_node("ErrorMessage")._create_error_message("Unique item already equipped", self)
				return
		if "legendary" in selected_storage_item.get_child(i):
			if selected_storage_item.get_child(i).name in legendary_items:
				Utility.get_node("ErrorMessage")._create_error_message("Legendary item already equipped", self)
				return

	# Check if item is a weapon, and if it's already equipped
	if storage.size() > 0:
		if GameManager.selected_character_name == "Ranger":
			if "range" in selected_storage_item.get_child(2):
				if selected_storage_item.get_child(2).range < 75:
					Utility.get_node("ErrorMessage")._create_error_message("Can't equip melee weapon", self)
					return
		if weapon_equipped:
			if "range" in it.get_child(2):
				for i in range(inventory.size()):
					if "range" in inventory[i].get_child(2):
						_add_from_inventory_to_storage(inventory[i])
						_on_storage_item_dropped(true)
						_on_item_picked_up(it)
						_update_inventory_test()
						selected_storage_item.get_child(0).get_child(0).visible = false
				return
		if inventory.size() < max_slots:
			_on_storage_item_dropped(true)
			_on_item_picked_up(it)
			_update_inventory_test()
			selected_storage_item.get_child(0).get_child(0).visible = false
		else:
			Utility.get_node("ErrorMessage")._create_error_message("Inventory full", self)


func _remove_item_stats_from_inventory():
	# Remove all stats from inventory, used for save/load
	for i in inventory.size():
		var children = inventory[i].get_children()
		if children.size() > 2:
			for j in range(2, children.size()):
				if "epic" in children[j]:
					_remove_item_effect(children[j].epic, children[j].tags[0], children[j].values[0])

				if "range" in children[j]:
					weapon_equipped = false
					current_weapon = null
				var removed_stats = {}
				for k in range(children[j]._get_tags().size()):
					removed_stats[children[j]._get_tags()[k]] = children[j]._get_values()[k]
				remove_stats.emit(removed_stats)

func _add_item_stats_from_inventory():
	# Add all stats from inventory, used for save/load
	for i in inventory.size():
		var children = inventory[i].get_children()
		if children.size() > 2:
			for j in range(2, children.size()):
				if "epic" in children[j]:
					_add_item_effect(children[j].epic, children[j].tags[0], children[j].values[0], children[j].duration, children[j].colors[0])

				if "range" in children[j]:
					weapon_equipped = true
					current_weapon = inventory[i].get_child(2)
				var added_stats = {}
				for k in range(children[j]._get_tags().size()):
					added_stats[children[j]._get_tags()[k]] = children[j]._get_values()[k]
				add_stats.emit(added_stats)

func _on_potion_picked_up(potion):
	if potions.size() < max_potion_slots:
		potion.player = get_parent()
		potions.append(potion)
		potion_charges.append(potion.charges)
		print(potion)
		_update_inventory_test()
	else:
		if storage.size() < max_storage_slots:
			storage.append(potion)
			_update_inventory_test()
			potion.remove_from_group("Items")
		else:
			Utility.get_node("ErrorMessage")._create_error_message("Storage full", self)
		return

func _on_potion_dropped(to_inventory = false):
	if potions.size() >= 0:
		if selected_potion:
			potions.erase(selected_potion)
			potion_charges.erase(potions.find(selected_potion)) 
			if !to_inventory:
				selected_potion._drop_item()
			_update_inventory_test()
		else:
			print("No potion selected")

func _on_potion_recharge_picked_up():
	for i in range(potions.size()):
		current_potion_charges[i] += 1
		if current_potion_charges[i] > potion_charges[i]:
			current_potion_charges[i] = potion_charges[i]
		_update_inventory_test()

func _on_get_item():
	item_selected.emit(selected_item)

func _on_level_pressed(ability_index : int):
	if unit.total_ability_experience >= abilities[ability_index].max_experience:
		unit.total_ability_experience -= abilities[ability_index].max_experience
		abilities[ability_index]._add_level()
	else:
		Utility.get_node('ErrorMessage')._create_error_message('Not enough experience to level' + str(abilities[ability_index].a_name), self)

func _handle_level_up_visability():
		for i in range(abilities.size()):
			if unit.total_ability_experience >= abilities[i].max_experience:
				hotbar.get_child(i).get_node('level_up').visible = true
			else:
				hotbar.get_child(i).get_node('level_up').visible = false

func _on_inventory_mouse_entered():
	unit.lose_camera_focus = true

func _on_inventory_mouse_exited():
	unit.lose_camera_focus = false

func _equipment_mouse_entered(index):
	if inventory.size() <= index:
		return
	unit.lose_camera_focus = true
	inventory[index].get_child(0).get_child(0).visible = true
	inventory[index]._show_tooltip_at_mouse()

func _equipment_mouse_exited(index):
	if inventory.size() <= index:
		return
	unit.lose_camera_focus = false
	inventory[index].get_child(0).get_child(0).visible = false

func _equipment_gui_input(event, index):
	if inventory.size() <= index:
		return
	if event is InputEventMouseButton:
		if event.double_click and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected_item = inventory[index]
			_on_item_dropped()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_item = inventory[index]
			_add_from_inventory_to_storage(selected_item)

func _potions_gui_input(event, index):
	if potions.size() <= index:
		return
	if event is InputEventMouseButton:
		if event.double_click and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected_potion = potions[index]
			_on_potion_dropped()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_potion = potions[index]
			_add_from_potions_to_storage(selected_potion)

func _storage_mouse_entered(index):
	if storage.size() <= index:
		return
	unit.lose_camera_focus = true
	storage[index].get_child(0).get_child(0).visible = true
	storage[index]._show_tooltip_at_mouse()

func _storage_mouse_exited(index):
	if storage.size() <= index:
		return
	unit.lose_camera_focus = false
	storage[index].get_child(0).get_child(0).visible = false

func _storage_gui_input(event, index):
	if storage.size() <= index:
		return
	if event is InputEventMouseButton:
		if event.double_click and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected_storage_item = storage[index]
			_on_storage_item_dropped()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_storage_item = storage[index]
			if "type" in storage[index]:
				if potions.size() < max_potion_slots:
					_on_storage_item_dropped(true)
					_on_potion_picked_up(selected_storage_item)
					_update_inventory_test()
					selected_storage_item.get_child(0).get_child(0).visible = false
				else:
					Utility.get_node("ErrorMessage")._create_error_message("Potion sack full", self)
			else:
				_add_from_storage_to_inventory(selected_storage_item)

func _potions_mouse_entered(index):
	if potions.size() <= index:
		return
	unit.lose_camera_focus = true
	potions[index].get_child(0).get_child(0).visible = true
	potions[index]._show_tooltip_at_mouse()

func _potions_mouse_exited(index):
	if potions.size() <= index:
		return
	unit.lose_camera_focus = false
	potions[index].get_child(0).get_child(0).visible = false

func _on_equipment_button_pressed():
	equipment_slots.visible = true
	statistics.visible = false

func _on_stats_button_pressed():
	equipment_slots.visible = false
	statistics.visible = true

func _on_hotbar_ability_mouse_entered(index):
	if abilities.size() <= index:
		return
	unit.lose_camera_focus = true
	tooltip.get_node('Panel/Name').text = "[center]" + abilities[index].name
	tooltip.get_node('Panel/PanelContainer/ScrollContainer/Description').text = "\n[center]" + abilities[index].tooltip
	tooltip.get_node('Panel/PanelContainer2/ScrollContainer/Description').text = "\n[center]" + abilities[index].secondary_tooltip
	tooltip.get_child(0).global_position = hotbar.get_child(index).global_position + Vector2((-tooltip.get_child(0).size.x/2) + (hotbar.get_child(index).size.x/2),-tooltip.get_child(0).size.y - 10)
	tooltip.visible = true

func _on_hotbar_character_mouse_entered(index):
	if index == 0:
		unit.lose_camera_focus = true
		tooltip.get_node('Panel/Name').text = "[center]" + unit.active_name
		tooltip.get_node('Panel/PanelContainer/ScrollContainer/Description').text = "\n[center]" + unit.active_tooltip
		tooltip.get_node('Panel/PanelContainer2/ScrollContainer/Description').text = "\n[center]" + unit.active_tooltip2
		tooltip.get_child(0).global_position = hotbar.get_node('TextureRect4').global_position + Vector2((-tooltip.get_child(0).size.x/2) + (hotbar.get_child(index).size.x/2),-tooltip.get_child(0).size.y - 10)
		tooltip.visible = true
	elif index == 1:
		unit.lose_camera_focus = true
		tooltip.get_node('Panel/Name').text = "[center]" + unit.passive_name
		tooltip.get_node('Panel/PanelContainer/ScrollContainer/Description').text = "\n[center]" + unit.passive_tooltip
		tooltip.get_node('Panel/PanelContainer2/ScrollContainer/Description').text = "\n[center]" + unit.passive_tooltip2
		tooltip.get_child(0).global_position = hotbar.get_node('TextureRect9').global_position + Vector2((-tooltip.get_child(0).size.x/2) + (hotbar.get_child(index).size.x/2),-tooltip.get_child(0).size.y - 10)
		tooltip.visible = true

func _on_hotbar_ability_mouse_exited(index):
	tooltip.visible = false
	unit.lose_camera_focus = false

func load_items():
	weapon_equipped = false
	for i in range(unit.im_inventory.size()):
		var the_item_data = unit.im_inventory[i]
		var the_item = unit.item_manager._load_item(the_item_data['bot_piece'], the_item_data['second_mid_piece'], the_item_data['mid_piece'], the_item_data['top_piece'], the_item_data['second_top_piece'], the_item_data['item_name'], the_item_data['rarity'])
		_on_item_picked_up(the_item)

	for i in range(unit.im_storage.size()):
		var the_item_data = unit.im_storage[i]
		var the_item
		if the_item_data.has("bot_piece"):
			the_item = unit.item_manager._load_item(the_item_data['bot_piece'], the_item_data['second_mid_piece'], the_item_data['mid_piece'], the_item_data['top_piece'], the_item_data['second_top_piece'], the_item_data['item_name'], the_item_data['rarity'])
		else:
			the_item = unit.item_manager._load_potion(the_item_data["item_name"], the_item_data["rarity"])
		storage.append(the_item)

	for i in range(unit.im_potions.size()):
		var the_potion_data = unit.im_potions[i]
		print("loaded: " + str(the_potion_data))
		var the_potion = unit.item_manager._load_potion(the_potion_data["item_name"], the_potion_data["rarity"])
		_on_potion_picked_up(the_potion)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if tooltip.visible == false:
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			tooltip.get_node('Panel/PanelContainer/ScrollContainer').scroll_vertical -= 3
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			tooltip.get_node('Panel/PanelContainer/ScrollContainer').scroll_vertical += 3
