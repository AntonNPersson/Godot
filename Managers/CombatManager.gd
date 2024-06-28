extends Node
@onready var health_bar = get_node("UI/ProgressBar")
@export var burn_effect : PackedScene
@export var freeze_effect : PackedScene
@export var hit_effect : PackedScene
@export var infected_effect : PackedScene
@export var combat_text : PackedScene

var invincible_units : Array = []
var pve_light_units : Array = []
var special_objects : Array = []
var player = null
var current_marked_pair = null

var recent_combat_text_targets = {}
var recent_combat_text_values = {}
var recent_combat_text_timestamps = {}
var recent_combat_text_instances = {}

var global_increases : Dictionary = {}
var global_defense_passives : Dictionary = {}

const COMBINE_TIME_PERIOD = 0.4

func _get_global_increases():
	global_increases = player.global_dict

func _has_global_increase(tag, user):
	if global_increases.has(tag) and user.is_in_group('players'):
		return true
	return false

func _get_global_protection_passive(tag):
	if global_defense_passives.has(tag):
		return global_defense_passives[tag].value

func _add_global_protection_passive(tag, value):
	global_defense_passives[tag] = value

func _calculate_evade_chance(value: float) -> float:
	var constant = 1000.0
	var evade_chance = value / (value + constant)
	var random = randi() % 100
	if random < evade_chance * 100:
		return true
	return false


func _ready():
	pass
# ------------------------------------------------------#
# Signal Handler
# ------------------------------------------------------#
func _on_do_action(value, target, user, tag, extra = null):
	match tag:
		"Explosion":
			_handle_explosion_action(user, value)
		"Pierce":
			_handle_pierce_action(user)
		"Duplicate":
			_handle_duplicate_action(user, value)
		"Experience":
			_handle_experience_action(target, value)
			return
		"QuickAttack":
			for i in tag:
				i = i.replace("Attack", "").replace("Buff", "")
			_handle_attack_action(user, value, extra, target)
			return
	_check_if_dead(target)
	
	_get_global_increases()
	if _has_global_increase(tag, user):
		value = value * ( 1 + global_increases[tag]/100)
	var damage = _calculate_reduced_damage(value, target.total_armor)

	match tag:
		"Damage":
			if _calculate_evade_chance(target.total_evade):
				_trigger_combat_text(target, 0, 'white')
				return
			_handle_damage_action(target, damage, tag, user)
		"AttackModifiers":
			_handle_modifier_action(user, target)
		"Lifesteal":
			_handle_lifesteal_action(user, damage, tag)
		"PercentArmorBuff":
			_handle_percent_armor_buff_action(target, value, user)
		"FrenzyBuff":
			_handle_frenzy_buff_action(target, value, user)
		"AttackBurnBuff":
			_handle_attack_buff_action(target, value, user, "Burn")
		"AttackFreezeBuff":
			_handle_attack_buff_action(target, value, user, "Freeze")
		"AttackDamageBuff":
			_handle_attack_buff_action(target, value, user, "Damage")
		"AttackSpeedBuff":
			_handle_attack_buff_action(target, value, user, "Speed")
		"AttackDamagePassive":
			_handle_attack_damage_passive(target, value)
		"AttackRangePassive":
			_handle_attack_range_passive(target, value)
		"MovementSpeedPassive":
			_handle_movement_speed_passive(target, value)
		"AttackSpeedPassive":
			_handle_attack_speed_passive(target, value)
		"ProtectionFreezePassive":
			_handle_protection_passive_action(target, value, "Freeze")
		"SpeedBuff":
			_handle_speed_buff_action(target, value, user)
		"PercentSpeedBuff":
			_handle_percent_speed_buff_action(target, value, user)
		"SelfInvincible":
			_handle_self_invincible_action(user, value)
		"Stealth":
			_handle_stealth_action(target, value)
		"Poison":
			_handle_poison_action(target, value, user)
		"Burn":
			_handle_burn_action(target, value, user)
		"Freeze":
			_handle_freeze_action(target, value,)
		"Shock":
			_handle_shock_action(target, value)
		"Heal":
			_handle_heal_action(target, value, tag)
		"Bleed":
			_handle_bleed_action(target, value, user)
		"Infected":
			_handle_infected_action(target)
		"Mark":
			_handle_mark_action(target, value, user)
		"PVEDarkness":
			_handle_pve_darkness_action(target, value, tag)
		"PVELight":
			_handle_pve_light_action(target, value, 1, user)
		"PVELightRemove":
			_handle_pve_light_action(target, value, 0, user)
	_update_boss_health_bar(target, user)
	_check_if_dead(target)

# ------------------------------------------------------#
# Helper methods
# ------------------------------------------------------#

func _barrier_protection(target, value):
	var rest_damage = value
	if target.is_in_group('players'):
		rest_damage = target.current_barrier - value
		target.current_barrier -= value
		if target.current_barrier < 0:
			target.current_barrier = 0
		if rest_damage > 0:
			rest_damage = 0
		_trigger_combat_text(target, value, 'blue')
	return abs(rest_damage)

func _apply_global_protection_passives(damage, user):
	for passive in global_defense_passives:
		if "Protection" in passive:
			var meta = passive.split("Protection")[1]
			if user.has_node(meta + "_timer"):
				damage = damage * ((100 - global_defense_passives[passive])/100)
	return damage

func _apply_shock(target, damage):
	if target.has_node('Shock_timer'):
		damage += 10 * target.get_meta('Shock_count')
	return damage

# Triggers the effects of a combat action on the target.
# Parameters:
# - target: The target of the combat action.
# - damage: The amount of damage dealt.
# - color: The color of the combat text.
func _trigger_effects(target, damage, color, tag):
	_trigger_combat_text(target, damage, color)
	if color != 'green':
		_trigger_hit_effect(target, tag)

# Handles experience gain for the player.
# Parameters:
# - target: The target of the experience gain.
# - value: The amount of experience to gain.
func _handle_experience_action(_target, value):
	_trigger_combat_text(player, value, 'Purple')
	if player.is_in_group('players'):
		player.total_ability_experience += value

# Handles the pierce action for the user.
# Parameters:
# - user: The user of the action.
func _handle_pierce_action(user):
	if user.projectile_type != 0:
		return
	user.line_pierce = true

func _handle_explosion_action(user, value):
	user.explosion = true
	user.explosion_radius = value

# Handles the duplicate action for the user.
# Parameters:
# - user: The user of the action.
# - value: The value to add to the user's amount.
func _handle_duplicate_action(user, value):
	if user.projectile_type != 0:
		return
	user.amount += value

# Handles the modifier action for the user.
# Parameters:
# - user: The user of the action.
# - target: The target of the action.
func _handle_modifier_action(user, target):
	var modifiers = user.current_attack_modifier_tags
	var values = user.current_attack_modifier_values
	for i in range(modifiers.size()):
		_on_do_action(values[i], target, user, modifiers[i])
# Handles the damage action on the target.
# Parameters:
# - target: The target of the action.
# - damage: The amount of damage to deal.
func _handle_damage_action(target, damage, tag, user):
	if target in invincible_units:
		return
	var new_damage = _apply_shock(target, _apply_global_protection_passives(damage, user))

	target.current_health -= _barrier_protection(target, new_damage)
	_trigger_effects(target, new_damage, 'white', tag)
	if target.has_node('Shock_timer'):
		await get_tree().create_timer(0.1).timeout
		if _check_if_dead(target):
			return
		_trigger_combat_text(target, 10 * target.get_meta('Shock_count'), 'yellow')

# Handles the attack range passive on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack range passive.
func _handle_attack_range_passive(target, value):
	if target.has_meta('AttackRangePassive') and target.get_meta('AttackRangePassive') == value:
		return
	if target.has_meta('AttackRangePassive'):
		target.bonus_range -= target.get_meta('AttackRangePassive')
	target.set_meta('AttackRangePassive', value)
	target.bonus_range += value
	if target.is_in_group('players'):
		target._update_stats()

# Handles the movement speed passive on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the movement speed passive.
func _handle_movement_speed_passive(target, value):
	if target.has_meta('MovementSpeedPassive') and target.get_meta('MovementSpeedPassive') == value:
		return
	if target.has_meta('MovementSpeedPassive'):
		target.bonus_speed -= target.get_meta('MovementSpeedPassive')
	target.set_meta('MovementSpeedPassive', value)
	target.bonus_speed += value
	if target.is_in_group('players'):
		target._update_stats()

# Handles the attack speed passive on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack speed passive.
func _handle_attack_speed_passive(target, value):
	if target.has_meta('AttackSpeedPassive') and target.get_meta('AttackSpeedPassive') == value:
		return
	if target.has_meta('AttackSpeedPassive'):
		target.bonus_attack_speed -= target.get_meta('AttackSpeedPassive')
	target.set_meta('AttackSpeedPassive', value)
	target.bonus_attack_speed += value
	if target.is_in_group('players'):
		target._update_stats()


func _handle_protection_passive_action(target, value, tag):
	if tag == "Freeze":
		if target.has_meta("ProtectionFreeze") and target.get_meta("ProtectionFreeze") == value:
			return
		_add_global_protection_passive("ProtectionFreeze", value)
		player.set_meta("ProtectionFreeze", value)
		return

func _handle_stealth_action(user, value):
	user.in_stealth = true
	var timer = Utility.get_node('TimerCreator')._create_timer(value, true, user)
	timer.timeout.connect(_deapply_stealth.bind(user))
	timer.start()


func _handle_attack_action(user, times, tags, values):
	for i in times:
		user.get_node('Control')._attack(tags, values)

# Handles the lifesteal action on the target.
# Parameters:
# - target: The target of the action.
# - damage: The amount of damage to heal.
func _handle_lifesteal_action(target, damage, tag):
	if target in invincible_units:
		return
	target.current_health += damage
	_trigger_effects(target, damage, 'green',tag)

func _handle_poison_action(target, value, user):
	if target in invincible_units or _check_if_dead(target):
		return
	var duration = 5
	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var damage_per_tick = value / total_ticks
	var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)
	target.set_meta('Poison_count', 0)
	timer.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'green', 'Poison'))
	var timer_index = 1
	var timer_name = "Poison_timer_" + str(timer_index)
	while target.has_node(timer_name):
		timer_index += 1
		timer_name = "Poison_timer_" + str(timer_index)
	target.add_child(timer)
	timer.start()
# Handles the frenzy buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the frenzy buff.
# - user: The duration of the frenzy buff.
func _handle_frenzy_buff_action(target, value, user):
	var duration = 2
	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var damage_per_tick = (target.total_health * 0.25) / total_ticks
	target.bonus_attack_speed += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "AttackSpeed"))
	target.add_child(timer)
	timer.start()
	target.add_child(timer)

	if !target.has_node('Frenzy_timer'):
		var timer2 = Utility.get_node('TimerCreator')._create_timer(1, false, target)
		target.set_meta('Frenzy_count', 0)
		target.set_meta('Frenzy_timer', true)
		timer2.name = "Frenzy_timer"
		timer2.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'red', 'Frenzy'))
		target.add_child(timer2)
		timer2.start()
	else:
		target.set_meta('Frenzy_count', 0)

# Handles the percent armor buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the armor buff.
# - user: The user of the action.
func _handle_percent_armor_buff_action(target, value, user):
	target.total_armor += (value/100) * target.total_armor
	if target.is_in_group('players'):
		target._update_stats()
	var timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Armor"))
	timer.start()

# Handles the percent speed buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the speed buff.
# - user: The user of the action.
func _handle_percent_speed_buff_action(target, value, user):
	var percent = value/100 * target.total_speed
	target.bonus_speed += percent
	if target.is_in_group('players'):
		target._update_stats()
	var timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	timer.timeout.connect(_deapply_buff.bind(target, percent, "Speed"))
	timer.start()

# Handles the attack buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack buff.
# - user: The user of the action.
# - tag: The tag associated with the attack buff.
func _handle_attack_buff_action(target, value, user, tag):
	if !target.is_in_group('players') or target.has_node(tag + "_timer"):
		return
	target.current_attack_modifier_tags.append(tag)
	target.current_attack_modifier_values.append(value)

	var timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	timer.name = tag + "_timer"
	timer.timeout.connect(_deapply_attack_buff.bind(target, value, tag))
	timer.start()

# Handles the attack damage passive on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack damage passive.
func _handle_attack_damage_passive(target, value):
	if target.has_meta('AttackDamagePassive') and target.get_meta('AttackDamagePassive') == value:
		return
	target.set_meta('AttackDamagePassive', value)
	target.bonus_attack_damage += value
	if target.is_in_group('players'):
		target._update_stats()

# Handles the speed buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the speed buff.
# - user: The user of the action.
func _handle_speed_buff_action(target, value, user):
	target.bonus_speed += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Speed"))
	timer.start()

# Handles the self invincible action on the user.
# Parameters:
# - user: The user of the action.
# - value: The duration of the invincibility.
func _handle_self_invincible_action(user, value):
	invincible_units.append(user)
	var timer = Utility.get_node('TimerCreator')._create_timer(value, true, user)
	timer.timeout.connect(_deapply_invincibility.bind(user))
	timer.start()

# Handles the burn action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of damage per tick.
# - user: The user of the action.
func _handle_burn_action(target, value, user):
	if target in invincible_units or _check_if_dead(target):
		return
	var duration = 5
	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var damage_per_tick = value / total_ticks

	if !target.has_node('Burn_timer'):
		var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)
		target.set_meta('Burn_count', 0)
		timer.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'orange', 'Burn'))
		timer.name = "Burn_timer"

		var burning = burn_effect.instantiate()
		burning.name = "Burn_effect"
		target.add_child(burning)
		timer.start()
	else:
		target.set_meta('Burn_count', 0)

# Handles the shock action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of damage to deal.
func _handle_shock_action(target, value):
	if target in invincible_units or _check_if_dead(target):
		return
	if target.has_node('Shock_timer'):
		target.set_meta('Shock_count', target.get_meta('Shock_count') + value)
		return
	target.set_meta('Shock_count', value)
	var duration = 5
	var timer = Utility.get_node('TimerCreator')._create_timer(duration, true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, 'Shock'))
	timer.name = "Shock_timer"
	target.add_child(timer)
	timer.start()

# Handles the freeze action on the target.
# Parameters:
# - target: The target of the action.
# - value: The percentage of speed reduction.
func _handle_freeze_action(target, value):
	var duration = 4.2
	var value_to_percent = value/100
	var new_speed = target.total_speed * value_to_percent
	var timer = Utility.get_node('TimerCreator')._create_timer(duration, true, target)
	timer.timeout.connect(_deapply_freeze.bind(new_speed, target))
	timer.name = "Freeze_timer"
	target.bonus_speed -= new_speed

	var freezing = freeze_effect.instantiate()
	freezing.name = "Freeze_effect"
	target.add_child(freezing)
	timer.start()

# Handles the heal action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of health to heal.
func _handle_heal_action(target, value, tag):
	target.current_health += value
	_trigger_effects(target, value, 'green', tag)

# Handles the bleed action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of damage per tick.
# - user: The user of the action.
func _handle_bleed_action(target, value, user):
	if target in invincible_units or _check_if_dead(target):
		return
	var duration = 2
	var tick_interval = 0.5
	var total_ticks = ceil(duration / tick_interval)
	var damage_per_tick = value / total_ticks

	if !target.has_node('Bleed_timer'):
		var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)
		target.set_meta('Bleed_count', 0)
		target.set_meta('Bleed_stacks', 1)
		timer.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'red', 'Bleed'))
		timer.name = "Bleed_timer"
		target.add_child(timer)
		timer.start()
	else:
		if target.get_meta('Bleed_stacks') >= 10:
			return
		target.set_meta('Bleed_count', 0)
		target.set_meta('Bleed_stacks', target.get_meta('Bleed_stacks') + 1)
		duration = 2

# Handles the infected action on the target.
# Parameters:
# - target: The target of the action.
func _handle_infected_action(target):
	if target in invincible_units or _check_if_dead(target):
		return
	var duration = 2
	var old_weight
	if !target.has_node('Infected_timer'):
		old_weight = target.global_weight
		var timer = Utility.get_node('TimerCreator')._create_timer(duration, true, target)
		timer.timeout.connect(_deapply_infected.bind(target, old_weight))
		timer.name = "Infected_timer"
		target.set_meta('Infected_stacks', 1)
		timer.start()
	else:
		target.get_node('Infected_timer').start(duration)
		if target.get_meta('Infected_stacks') >= 10:
			return
		target.set_meta('Infected_stacks', target.get_meta('Infected_stacks') + 1)

	target.global_weight += 5 * target.get_meta('Infected_stacks')
	if !target.has_node('Infected_effect'):
		var infected = infected_effect.instantiate()
		infected.name = "Infected_effect"
		target.add_child(infected)

# Handles the mark action on the target.
# Parameters:
# - target: The target of the action.
# - value: The duration of the mark.
# - user: The user of the action.
func _handle_mark_action(target, value, user):
	current_marked_pair[0] = target
	current_marked_pair[1] = user
	var timer = Utility.get_node('TimerCreator')._create_timer(value, true, target)
	timer.timeout.connect(_deapply_mark.bind(target))
	timer.start()

# Handles the PvE darkness action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of damage to deal.
func _handle_pve_darkness_action(target, value, tag):
	if pve_light_units.has(target) or _check_if_dead(target):
		return
	target.current_health -= value
	_trigger_effects(target, value, 'Darkviolet', tag)

# Handles the PvE light action on the target.
# Parameters:
# - target: The target of the action.
# - value: The duration of the light.
func _handle_pve_light_action(target, value, type, user):
	if _check_if_dead(target):
		return
	if type == 1:
		pve_light_units.append(target)
		special_objects.append(user)
	if type == 0:
		if target in pve_light_units and user in special_objects:
			pve_light_units.clear()
			special_objects.erase(user)
	return

# ------------------------------------------------------#
# Timeout Handler
# ------------------------------------------------------#

# This function removes a target from an array.
# Parameters:
#   - arr: The array from which to remove the target.
#   - target: The target to be removed from the array.
func _deapply_pve_light(arr, target):
	arr.erase(target)

# This function calculates the reduced damage based on the armor value.
# Parameters:
#   - damage: The original damage value.
#   - armor: The armor value of the target.
# Returns:
#   - The reduced damage value.
func _calculate_reduced_damage(damage, armor):
	var value = damage * (1 - (armor/(armor + 1000)))
	if value < 0:
		return 0
	return value

# This function deapplies the effects of being infected from a target.
# Parameters:
#   - target: The target from which to deapply the effects.
#   - old_weight: The original weight value of the target.
func _deapply_infected(target, old_weight):
	target.global_weight = old_weight
	target.set_meta('Infected_stacks', 0)
	target.get_node('Infected_effect').queue_free()

# This function deapplies an attack buff from a target.
# Parameters:
#   - target: The target from which to deapply the attack buff.
#   - value: The value of the attack buff.
#   - tag: The tag associated with the attack buff.
func _deapply_attack_buff(target, value, tag):
	target.current_attack_modifier_tags.erase(tag)
	target.current_attack_modifier_values.erase(value)

# This function deapplies the mark effect from a target.
# Parameters:
#   - _target: The target from which to deapply the mark effect.
func _deapply_mark(_target):
	current_marked_pair[0] = null
	current_marked_pair[1] = null

# This function deapplies the invincibility effect from a user.
# Parameters:
#   - user: The user from which to deapply the invincibility effect.
func _deapply_invincibility(user):
	invincible_units.erase(user)

# This function deapplies the freeze effect from a target.
# Parameters:
#   - original_speed: The original speed value of the target.
#   - target: The target from which to deapply the freeze effect.
func _deapply_freeze(original_speed, target):
	if !target.has_node('Freeze_effect'):
		return
	target.bonus_speed += original_speed
	target.get_node('Freeze_timer').queue_free()
	target.get_node('Freeze_effect').queue_free()

# This function deapplies the stealth effect from a user.
# Parameters:
#   - user: The user from which to deapply the stealth effect.
func _deapply_stealth(user):
	user.in_stealth = false

# This function deapplies a buff from a target.
# Parameters:
#   - target: The target from which to deapply the buff.
#   - value: The value of the buff.
#   - tag: The tag associated with the buff.
func _deapply_buff(target, value, tag):
	if tag == "Armor":
		target.bonus_armor -= value
	if tag == "Speed":
		target.bonus_speed -= value
	if tag == "AttackSpeed":
		target.bonus_attack_speed -= value
	if tag == "Shock":
		target.get_node('Shock_timer').queue_free()
		target.set_meta('Shock_count', 0)
	if target.is_in_group('players'):
		target._update_stats()

# This function applies damage over time to a target.
# Parameters:
#   - target: The target to apply the damage over time effect.
#   - damage_per_tick: The amount of damage to apply per tick.
#   - user: The user who applied the damage over time effect.
#   - total_ticks: The total number of ticks for the damage over time effect.
#   - color: The color of the damage text.
#   - type: The type of damage over time effect (e.g., "Bleed", "Burn").
func _apply_damage_over_time(target, damage_per_tick, user, total_ticks, color, type):
	if target in invincible_units or _check_if_dead(target):
		return

	var damage
	if type == "Bleed":
		damage = _calculate_reduced_damage(damage_per_tick * target.get_meta('Bleed_stacks'), target.total_armor)
	elif type == "Frenzy":
		damage = damage_per_tick
	elif type == "Poison":
		damage = damage_per_tick
	else:    
		damage = _calculate_reduced_damage(damage_per_tick, target.total_armor)

	target.current_health -= _barrier_protection(target, damage)

	if target.is_in_group("enemies"):
		_trigger_combat_text(target, damage, color)
	
	var current_tick = target.get_meta(type + "_count")
	target.set_meta(type + "_count", current_tick + 1)

	if current_tick >= total_ticks:
		if _check_if_dead(target):
			return
		if type == "Burn":
			target.get_node("Burn_effect").queue_free()
			return
		if target.has_node(type + "_timer"):
			target.get_node(type + "_timer").queue_free()
	_update_boss_health_bar(target, user)
	_trigger_hit_effect(target, type)
	if _check_if_dead(target):
		return

#------------------------------------------------------#
# Extras signals and methods
#------------------------------------------------------#
func _on_character_selected(unit):
	unit.get_node('Control').on_action.connect(_on_do_action)
	player = unit

func _update_sub_wave(_number, arr):
	for child in arr:
		child.do_action.connect(_on_do_action)

func _on_start_wave(value, _value):
	for child in value.get_children():
		child.do_action.connect(_on_do_action)
		
func _update_boss_health_bar(target, _user):
	if target.is_in_group('boss'):
		health_bar.visible = true
		var percentage = target._calculate_health_percentage()
		health_bar._update_health(percentage)
		
	
func _check_if_dead(unit):
	if !is_instance_valid(unit):
		return true
	if unit.is_queued_for_deletion():
		return true
	if unit.current_health <= 0:
		unit.is_dead.emit(unit)
		unit.set_meta('dying', true)
		return true
	return false

func _on_death_animation_finished(unit):
		unit.queue_free()
	
func _on_stop_wave(_completed, _value):
	health_bar.visible = false
	
func _trigger_hit_effect(target, tag):
	if _check_if_dead(target) or target.is_queued_for_deletion():
		return

	target.set_meta("hit_effect", true)
	var sprite = target.get_node('AnimatedSprite2D')
	var original_material = sprite.material
	var new_material = original_material.duplicate()
	
	new_material.set_shader_parameter("hit_effect_intensity", 0.6)
	sprite.material = new_material
	if target.is_in_group('enemies') and tag == "Damage":
		if !target.is_in_group('boss'):
			target.do_action.emit(-target.total_speed, target, 0.2, "SpeedBuff")
		if !target.has_node('HitEffect'):
			var instance = hit_effect.instantiate()
			target.add_child(instance)
			var random = randi_range(0, 2)
			instance.get_node('AnimatedSprite2D').play(str(random))


	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.2
	timer.timeout.connect(_deapply_trigger_effect.bind(target, original_material))
	target.add_child(timer)
	timer.start()

func _deapply_trigger_effect(target, original_material):
	original_material.set_shader_parameter('hit_effect_intensity', 0.0)
	target.get_node('AnimatedSprite2D').material = original_material
	target.set_meta("hit_effect", false)
	
func _create_combat_text_and_update_recent(value, current_time, target, color):
	recent_combat_text_values[target][color] = value
	recent_combat_text_timestamps[target][color] = current_time
	var instanced = combat_text.instantiate()
	recent_combat_text_instances[target][color] = instanced
	instanced._create_text(recent_combat_text_values[target][color], target, color)

func _trigger_combat_text(target, value, color):
	var current_time = Time.get_ticks_msec() / 1000.0
	if value <= 1:
		return

	if recent_combat_text_values.has(target):
		if recent_combat_text_values[target].has(color):
			if (current_time - recent_combat_text_timestamps[target][color]) < COMBINE_TIME_PERIOD:
				recent_combat_text_values[target][color] += value
				recent_combat_text_instances[target][color]._update_text(recent_combat_text_values[target][color])
				return
			else:
				_create_combat_text_and_update_recent(value, current_time, target, color)
				return
		else:
			_create_combat_text_and_update_recent(value, current_time, target, color)
			return
	else:
		recent_combat_text_values[target] = {}
		recent_combat_text_timestamps[target] = {}
		recent_combat_text_instances[target] = {}
		_create_combat_text_and_update_recent(value, current_time, target, color)
		return

