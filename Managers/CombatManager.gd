extends Node
@onready var health_bar = get_node("UI/ProgressBar")
@export var burn_effect : PackedScene
@export var freeze_effect : PackedScene
@export var frozen_effect : PackedScene
@export var hit_effect : PackedScene
@export var infected_effect : PackedScene
@export var combat_text : PackedScene
@export var explosion_effect : PackedScene
@export var heal_effect : PackedScene
@export var root_effect : PackedScene
@export var stun_effect : PackedScene
@export var taunt_effect : PackedScene
@export var weaken_effect : PackedScene

@export var map_manager : Node
@export var ability_manager : Node

var invincible_units : Array = []
var knockback_units : Array = []
var pulled_units : Array = []
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

var burn_effect_values = {}
var frozen_effect_values = {}
var poison_effect_values = {}
var bleed_effect_values = {}
var shock_effect_values = {}
var extra_effect_values = {}

var timers = {}

var poisoned_targets = []
var poisoned_stacks_name = 0

var bleed_targets = []
var bleed_stacks_name = 0

var frozen_targets = []
var frozen_stacks_name = 0

var last_combat_text_target = null

var end_action_abilities = []

signal enemy_basic_attacking(origin)

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

func _remove_global_protection_passive(tag):
	if global_defense_passives.has(tag):
		global_defense_passives.erase(tag)

func _calculate_evade_chance(value: float) -> float:
	var constant = 1000.0
	var evade_chance = value / (value + constant)
	var random = randi() % 100
	if random < evade_chance * 100:
		return true
	return false


func _ready():
	enemy_basic_attacking.connect(_on_enemy_basic_attack)

func _process(delta):

	if timers.size() > 0:
		if timers.has("ChaosMagic"):
			if typeof(timers["ChaosMagic"]) == TYPE_FLOAT or typeof(timers["ChaosMagic"]) == TYPE_INT:
				timers["ChaosMagic"] -= delta
		if timers.has("BurnExplosion"):
			if typeof(timers["BurnExplosion"]) == TYPE_FLOAT or typeof(timers["BurnExplosion"]) == TYPE_INT:
				timers["BurnExplosion"] -= delta

	if extra_effect_values.size() > 0:
		if extra_effect_values.has("Convergance"):
			if player.bonus_range != 0:
				player.global_attack_damage -= extra_effect_values["Convergance"] / 2.0
				extra_effect_values['Convergance'] = extra_effect_values['Convergance'] + player.bonus_range
				player.global_attack_damage += extra_effect_values['Convergance'] / 2.0
				player.bonus_range = 0
				player._update_stats()

		if extra_effect_values.has("LastStand"):
			for abilityy in player.get_node('InventoryManager').abilities:
				abilityy.lowest_cooldown = abilityy.cooldown * (1 - 80/100.0)
			extra_effect_values["LastStand"] = player.bonus_cooldown_reduction - 80

		if extra_effect_values.has("DreadWarden"):
			if player.bonus_attack_speed != extra_effect_values["DreadWarden"]:
				player.global_attack_damage -= extra_effect_values["DreadWarden"]
				extra_effect_values["DreadWarden"] = player.bonus_attack_speed
				player.global_attack_damage += extra_effect_values["DreadWarden"]
				player._update_stats()

		if extra_effect_values.has("DexterityStatConversion"):
			var extra = {"ability": extra_effect_values["DexterityStatConversionAbility"]}
			_on_do_action(extra_effect_values["DexterityStatConversion"], player, player, "StrengthToDexterityConversion", extra)
			_on_do_action(extra_effect_values["DexterityStatConversion"], player, player, "IntelligenceToDexterityConversion", extra)
		
		if extra_effect_values.has("IntelligenceStatConversion"):
			var extra = {"ability": extra_effect_values["IntelligenceStatConversionAbility"]}
			_on_do_action(extra_effect_values["IntelligenceStatConversion"], player, player, "StrengthToIntelligenceConversion", extra)
			_on_do_action(extra_effect_values["IntelligenceStatConversion"], player, player, "DexterityToIntelligenceConversion", extra)

		if extra_effect_values.has("StrengthStatConversion"):
			var extra = {"ability": extra_effect_values["StrengthStatConversionAbility"]}
			_on_do_action(extra_effect_values["StrengthStatConversion"], player, player, "DexterityToStrengthConversion", extra)
			_on_do_action(extra_effect_values["StrengthStatConversion"], player, player, "IntelligenceToStrengthConversion", extra)

		if extra_effect_values.has("LowHealthInvincible"):
			extra_effect_values["LowHealthInvincibleCooldown"] -= delta
			if extra_effect_values["LowHealthInvincibleCooldown"] <= 0:
				if player.current_health <= player.total_health * (extra_effect_values["LowHealthInvincible"]/100.0):
					var extra = {"ability": "LowHealthInvincible"}
					_on_do_action(3, player, player, "SelfInvincible", extra)
					extra_effect_values["LowHealthInvincibleCooldown"] = 30

	if knockback_units.size() > 0:
		for unit in knockback_units:
			if _check_if_dead(unit) or !unit.has_meta('Knockback_origin'):
				knockback_units.erase(unit)
				continue

			if !unit.is_in_group('players'):
				unit.is_rooted = true

			if unit.is_colliding:
				if !unit.is_in_group('players'):
					unit.is_rooted = false
				unit.global_position -= unit.get_meta('Knockback_direction').normalized() * 10
				knockback_units.erase(unit)
				unit.remove_meta('Knockback_origin')
				continue

			var origin = unit.get_meta('Knockback_origin')
			var direction = unit.get_meta('Knockback_direction').normalized()
			var max_distance = unit.get_meta('Knockback_distance')
			var current_distance = unit.global_position.distance_to(origin)
			if current_distance >= max_distance - 5:
				if !unit.is_in_group('players'):
					unit.is_rooted = false
				knockback_units.erase(unit)
				unit.remove_meta('Knockback_origin')
				continue
			
			var speed = lerp(200, 25, current_distance / max_distance)
			unit.global_position += direction * speed * delta
	
	if pulled_units.size() > 0:
		for unit in pulled_units:
			if _check_if_dead(unit) or !unit.has_meta('Pull_origin'):
				pulled_units.erase(unit)
				continue

			if unit.is_colliding:
				unit.is_rooted = false
				pulled_units.erase(unit)
				unit.remove_meta('Pull_origin')
				continue

			var origin = unit.get_meta('Pull_origin')
			var direction = unit.get_meta('Pull_direction').normalized()
			var max_distance = unit.get_meta('Pull_distance')
			var current_distance = unit.global_position.distance_to(origin)
			if current_distance >= max_distance - 5:
				unit.is_rooted = false
				pulled_units.erase(unit)
				unit.remove_meta('Pull_origin')
				unit.remove_meta('Pull_direction')
				unit.remove_meta('Pull_distance')
				continue
			
			var speed = lerp(200, 25, current_distance / max_distance)
			unit.global_position += direction * speed * delta
			unit.is_rooted = true
	
		
	
# PERCENTAGE INCREASES ALWAYS ADDS TO GLOBAL VERSION OF THE STAT, AS TO NOT BE AFFECTED BY OTHER PERCENTAGE INCREASES
# ------------------------------------------------------#
# Signal Handler
# ------------------------------------------------------#
func _on_do_action(value, target, user, tag, extra = null):
	if extra != null:
		if extra.has("enemy_basic_attacking"):
			enemy_basic_attacking.emit(extra["enemy"])

	match tag:
		"AbilityPercentDamage":
			_handle_ability_percent_damage_action(user, value)
			return
		"AbilityPercentCooldownReduction":
			_handle_ability_percent_cooldown_reduction_action(user, value)
			return
		"AreaPool":
			_handle_area_pool_action(user, value, extra)
			return
		"Ascension":
			_handle_ascension_action(target, value)
			return
		"BoostManaRegen":
			_handle_boost_mana_regen_action(target, value, user)
			return
		"BoostManaRegenPercent":
			_handle_boost_mana_regen_percent_action(target, value, user)
			return
		"BoostManaRegenPassive":
			_handle_boost_mana_regen_passive_action(target, value, extra['ability'])
		"BurnHeal":
			_handle_burn_heal_action(target, value)
			return
		"BurnPercentDamage":
			_handle_burn_percent_damage_action(target, value, user)
			return
		"BurnExplosion":
			_handle_burn_explosion_action(target, value, extra['Radius'], user)
			return
		"BurnDuration":
			_handle_burn_duration_action(target, value, user)
			return
		"CascadeRefresh":
			_handle_cascade_refresh_action(target, value)
			return
		"ChaosMagic":
			_handle_chaos_magic_action(target, value, extra)
			return
		"ChronosBlessing":
			_handle_chronos_blessing_action(target, value, user)
			return
		"DamagingTeleport":
			_handle_damaging_teleport_action(target, value)
			return
		"Duplicate":
			_handle_duplicate_action(user, value)
			return
		"DyingBreath":
			_handle_dying_breath_action(target, value, extra['ability'])
			return
		"Multistrike":
			_handle_multistrike_action(target, value, user)
			return
		"Echo":
			_handle_echo_action(user, value)
			return
		"Experience":
			_handle_experience_action(target, value)
			return
		"Explosion":
			_handle_explosion_action(user, value)
			return
		"ElementalSymbiosis":
			_handle_elemental_symbiosis_action(target, value, extra)
			return
		"FreezeAmount":
			_handle_freeze_amount_action(target, value, user)
			return
		"FrozenChance":
			_handle_frozen_chance_action(target, value, user)
			return
		"FrozenPercentageDamageBuff":
			_handle_frozen_percentage_damage_buff_action(target, value)
			return
		"FrozenQuickAttack":
			_handle_frozen_quick_attack_action(target, value)
			return
		"LuckyPoison":
			_handle_lucky_poison_action(target, value, extra)
			return
		"LuckyBleed":
			_handle_lucky_bleed_action(target, value, extra)
			return
		"MovementPenalty":
			_handle_movement_penalty_action(target, value, user)
			return
		"MovementPenaltyBuff":
			_handle_movement_penalty_buff_action(target, value)
			return
		"MovementCharges":
			_handle_movement_charges_action(value, user)
		"Pierce":
			_handle_pierce_action(user)
			return
		"Split":
			_handle_split_action(user, value)
			return
		"Ricochet":
			_handle_ricochet_action(user, value)
			return
		"Spread":
			#_handle_spread_action(user, value)
			return
		"Swap":
			_handle_swap_action(user)
			return
		"PoisonAttack":
			_handle_poison_attack_action(target, value)
			return
		"BleedAttack":
			_handle_bleed_attack_action(target, value)
			return
		"ProjectileSpeed":
			_handle_projectile_speed_action(user, value)
			return
		"PassiveActivate":
			_handle_passive_activate_action(user, value)
			return
		"AreaRadius":
			_handle_area_radius_action(user, value)
			return
		"QuickAttack":
			_handle_attack_action(user, value, extra, target)
			return
		"SelfTarget":
			_handle_self_target_action(target, user)
			return
		"TheConvergance":
			_handle_converganace_action(user, value, target)
			return
		"TheLastStand":
			_handle_last_stand_action(user, target, value)
			return
		"TheSurvival":
			_handle_survival_action(user, target, value)
			return
		"TheDreadWarden":
			_handle_dread_warden_action(user, target, value)
			return
		"VampiricalHeal":
			_handle_vampirical_heal_action(target, value)
			return
		"SummonFlatHealth":
			_handle_summon_flat_health_action(value, user)
			return
		"SummonPercentageHealth":
			_handle_summon_percentage_health_action(value, user)
			return
		"SummonFlatAttackDamage":
			_handle_summon_flat_attack_damage_action(value, user)
			return
		"SummonPercentageAttackDamage":
			_handle_summon_percentage_attack_damage_action(value, user)
			return
		"SummonFlatArmor":
			_handle_summon_flat_armor_action(value, user)
			return
		"SummonPercentageArmor":
			_handle_summon_percentage_armor_action(value, user)
			return
		"SummonFlatAttackSpeed":
			_handle_summon_flat_attack_speed_action(value, user)
			return
		"SummonFlatEvade":
			_handle_summon_flat_evade_action(value, user)
			return
		"SummonPercentageEvade":
			_handle_summon_percentage_evade_action(value, user)
			return
		"SummonAbility":
			_handle_summon_ability_action(user, extra)
			return
	_check_if_dead(target)
	
	if _check_if_dead(get_tree().get_nodes_in_group("players")[0]):
		return
	if get_tree().get_nodes_in_group("players")[0].paused:
		return
	_get_global_increases()
	if _has_global_increase(tag, user):
		value = value * ( 1.0 + global_increases[tag]/100.0)
	var damage = _calculate_reduced_damage(value, target.total_armor)

	match tag:
		"AdrenalineRush":
			_handle_adrenaline_rush_action(target, user, value, extra)
		"AfflictionBuff":
			_handle_affliction_buff_action(target, value, extra)
		"ArcaneDamagePassive":
			_handle_arcane_damage_passive(target, value, extra['ability'])
		"WindSpeedPassive":
			_handle_wind_speed_passive(target, value, extra['ability'])
		"AttackBurnBuff":
			_handle_attack_buff_action(target, value, user, "Burn", extra)
		"AttackDamageBuff":
			_handle_attack_buff_action(target, value, user, "Damage", extra)
		"AttackDamagePassive":
			_handle_attack_damage_passive(target, value, extra['ability'])
		"AttackFreezeBuff":
			_handle_attack_buff_action(target, value, user, "Freeze", extra)
		"AttackModifiers":
			_handle_modifier_action(user, target)
			return
		"AttackRangePassive":
			_handle_attack_range_passive(target, value, extra['ability'])
		"AttackSpeedBuff":
			_handle_attack_speed_buff_action(target, value, extra)
		"AttackSpeedPassive":
			_handle_attack_speed_passive(target, value, extra['ability'])
		"AttackTargetPassive":
			_handle_attack_target_passive(target, value, extra['ability'])
		"Bleed":
			_handle_bleed_action(target, value, user, extra)
		"BleedStackConsumeHeal":
			_handle_bleed_stack_consume_heal_action(target, value, user, extra)
		"BleedReflectPassive":
			_handle_bleed_reflect_action(target, value, extra['ability'])
		"Burn":
			_handle_burn_action(target, value, user, extra)
		"BurnReflectBuff":
			_handle_burn_reflect_buff_action(target, value, extra)
		"BasicAttackDamage":
			_handle_basic_attack_damage_action(target, value, user)
		"CrimsonReckoning": # Toggle Passive
			_handle_crimson_reckoning_action(user, value, extra)
		"CrimsonSalvation": # Toggle Passive
			_handle_crimson_salvation_action(user, value, extra)
		"CriticalChanceBuff":
			_handle_crit_chance_buff_action(target, value, extra)
		"CriticalChancePassive":
			_handle_critical_chance_passive(target, value, extra['ability'])
		"CriticalDamagePassive":
			_handle_critical_damage_passive(target, value, extra['ability'])
		"CrowdControlExtraFlatDamage":
			_handle_crowd_control_extra_flat_damage_action(target, value)
		"CooldownResetOnKill":
			_handle_cooldown_reset_on_kill_action(target, extra)
		"Damage":
			if _calculate_evade_chance(target.total_evade):
				_on_evade(target, user)
				_trigger_combat_text(target, 0, 'Springgreen')
				return
			_handle_damage_action(target, damage, tag, user, extra)
		"DetonateBurn":
			_handle_detonate_burn_action(target, value, user)
		"DexterityStatConversion":
			_handle_dexterity_stat_conversion_action(user, value, extra)
		"DexterityToStrengthConversion":
			_handle_dexterity_to_strength_conversion(target, value, extra['ability'])
		"DexterityToIntelligenceConversion":
			_handle_dexterity_to_intelligence_conversion(target, value, extra['ability'])
		"DoubleCastPassive":
			_handle_double_cast_passive(target, value, extra['ability'])
		"Execute":
			_handle_execute_action(target, value, user)
		"Ferver":
			_handle_ferver_action(user, value, extra)
		"FlatEvadeBuff":
			_handle_evade_buff_action(target, value, extra)
		"FlatEvadePassive":
			_handle_flat_evade_passive(target, value, extra['ability'])
		"FlatThornsBuff":
			_handle_flat_thorns_buff_action(target, value, extra)
		"FlatThornsPassive":
			_handle_flat_thorns_passive(target, value, extra['ability'])
		"Frozen":
			_handle_frozen_action(target, value, user, extra)
		"Freeze":
			_handle_freeze_action(target, value, user, extra)
		"FreezeExtraFlatDamage":
			_handle_freeze_extra_flat_damage_action(target, value)
		"FrozenChancePassive":
			_handle_frozen_chance_passive(target, value, extra['ability'])
		"FrenzyBuff":
			_handle_frenzy_buff_action(target, value, user, extra)
		"FlatArmorBuff":
			_handle_flat_armor_buff_action(target, value, extra)
		"FlatArmorDebuff":
			_handle_flat_armor_debuff_action(target, value, extra)
		"GravityPull":
			_handle_gravity_pull_action(target, value, user)
		"Heal":
			_handle_heal_action(target, value, tag, user)
		"HealOverTime":
			_handle_heal_over_time_action(target, value, user, extra)
		"HealManaOverTime":
			_handle_heal_mana_over_time_action(target, value, user, extra)
		"PercentHealManaOverTime":
			_handle_percent_heal_mana_over_time_action(target, value, user, extra)
		"PercentHealOverTime":
			_handle_percent_heal_over_time_action(target, value, user, extra)
		"PercentHeal":
			_handle_heal_action(target, target.total_health * (value/100.0), tag, user)
		"IntelligenceStatConversion":
			_handle_intelligence_stat_conversion_action(user, value, extra)
		"IntelligenceToDexterityConversion":
			_handle_intelligence_to_dexterity_conversion(target, value, extra['ability'])
		"IntelligenceToStrengthConversion":
			_handle_intelligence_to_strength_conversion(target, value, extra['ability'])
		"Infected":
			_handle_infected_action(target)
		"Lifesteal":
			_handle_lifesteal_action(user, damage, tag)
		"LifeStealPassive":
			_handle_life_steal_passive(target, value, extra['ability'])
		"LowHealthInvincible":
			_handle_low_health_invincible_action(extra, value)
		"Mark":
			_handle_mark_action(target, value, user)
		"ManaOverload":
			_handle_mana_overload_action(target, value, user, extra)
		"ManaShieldOn":
			_handle_mana_shield_action(true, value, extra)
		"ManaShieldOff":
			_handle_mana_shield_action(false, value, extra)
		"MovementSpeedPassive":
			_handle_movement_speed_passive(target, value, extra['ability'])
		"PercentArmorBuff":
			_handle_percent_armor_buff_action(target, value, user, extra)
		"PercentArmorDebuff":
			_handle_percent_armor_debuff_action(target, value, user, extra)
		"PercentAttackDamageBuff":
			_handle_percent_attack_buff_action(target, value, user, extra)
		"PercentAttackDamagePassive":
			_handle_percent_attack_damage_passive(target, value, extra['ability'])
		"PercentSpeedBuff":
			_handle_percent_speed_buff_action(target, value, user, extra)
		"PercentDamageBuff":
			_handle_percent_damage_buff_action(target, value, user, extra)
		"PercentDamagePassive":
			_handle_percent_damage_passive(target, value, extra['ability'])
		"PercentHealthBuff":
			_handle_percent_health_buff_action(target, value, user, extra)
		"PercentSizeBuff":
			_handle_percent_size_buff_action(target, value, user, extra)
		"PercentPoisonDamageBuff":
			_handle_percent_poison_damage_buff_action(target, value, user, extra)
		"Poison":
			_handle_poison_action(target, value, user)
		"PoisonExtraStack":
			_handle_poison_extra_stack_action(target, value)
		"ProtectionFreezePassive":
			_handle_protection_passive_action(target, value, "Freeze", extra['ability'])
		"PVEDarkness":
			_handle_pve_darkness_action(target, value, tag)
		"PVELight":
			_handle_pve_light_action(target, value, 1, user)
		"PVELightRemove":
			_handle_pve_light_action(target, value, 0, user)
		"QuickAttackPassive":
			_handle_quick_attack_passive(target, value, extra['ability'])
		"RefundMana":
			_handle_refund_mana_action(target, value, extra)
		"ReduceCooldowns":
			_handle_reduce_cooldowns_action(target, value, extra)
		"RelentlessPrecision":
			_handle_relentless_precision_action(user, value, extra)
		"Root":
			_handle_root_action(target, value)
		"RageRegenBuff":
			if !GameManager.selected_character_name == "Warrior":
				return
			_handle_rage_regen_buff_action(target, value, extra)
		"UmbralSnare":
			_handle_umbral_snare_action(target, value, user, extra)
		"SelfInvincible":
			_handle_self_invincible_action(user, value, extra)
		"Shock":
			_handle_shock_action(target, value)
		"SpeedBuff":
			_handle_speed_buff_action(target, value, user, extra)
		"Stealth":
			_handle_stealth_action(target, value)
		"Stun":
			_handle_stun_action(target, value)
		"StunExtraFlatDamage":
			_handle_stun_extra_flat_damage_action(target, value)
		"SpellVampPassive":
			_handle_spell_vamp_passive(target, value, extra['ability'])
		"StrengthStatConversion":
			_handle_strength_stat_conversion_action(user, value, extra)
		"StrengthToVitalityPassive":
			_handle_strength_to_vitality_passive(target, value, extra['ability'])
		"StrengthToDexterityConversion":
			_handle_strength_to_dexterity_conversion(target, value, extra['ability'])
		"StrengthToIntelligenceConversion":
			_handle_strength_to_intelligence_conversion(target, value, extra['ability'])
		"Taunt":
			_handle_taunt_action(target, value, user)
		"Wind":
			_handle_wind_action(target, value, user)
		"Weaken":
			_handle_weaken_action(target, value)
	_update_boss_health_bar(target, user)
	_check_if_dead(target)

# ------------------------------------------------------#
# Helper methods
# ------------------------------------------------------#

func _calculate_damage(value, target):
	var damage = _calculate_reduced_damage(value, target.total_armor)
	return damage

func _check_if_kills(target, _damage):
	var damage = _calculate_damage(_damage, target)
	if target.current_health - damage <= 0:
		return true
	return false

func _barrier_protection(target, value):
	var rest_damage = value
	if target.is_in_group('players'):
		rest_damage = value - target.current_barrier
		target.current_barrier -= value
		if target.current_barrier < 0:
			target.current_barrier = 0
		if rest_damage < 0:
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

func _chance_calculator(chance):
	var random = randi() % 100
	if random < chance:
		return true
	return false

func find_first_matching_index(array, values):
	for value in values:
		var index = array.find(value)
		if index != -1:
			return index
	return -1

func _on_evade(target, user):
	if GameManager.selected_character_name == "Duelist":
		target.get_node("Control")._attack([], [], 0, null, 70, user)

func _on_cast(ab):
	if extra_effect_values.has("ElementalSymbiosis"):
		var extra = {"ability": "ElementalSymbiosis"}
		var effects = ["Burn", "Freeze", "Poison", "Shock", "Bleed"]
		var current_effect_index = find_first_matching_index(ab.tags, effects)
		if !ab.tags.has(extra_effect_values["ElementalSymbiosisLastEffect"]):
			if extra_effect_values["ElementalSymbiosisCurrentStack"] >= extra_effect_values["ElementalSymbiosisMaximumStack"]:
				return
			extra_effect_values["ElementalSymbiosisCurrentStack"] += 1
			_on_do_action(extra_effect_values["ElementalSymbiosis"] * extra_effect_values["ElementalSymbiosisCurrentStack"], player, player, "PercentDamagePassive", extra)
		else:
			extra_effect_values["ElementalSymbiosisCurrentStack"] = 0
			_on_do_action(extra_effect_values["ElementalSymbiosis"] * extra_effect_values["ElementalSymbiosisCurrentStack"], player, player, "PercentDamagePassive", extra)
		if current_effect_index != -1:
			extra_effect_values["ElementalSymbiosisLastEffect"] = ab.tags[current_effect_index]
		else:
			extra_effect_values["ElementalSymbiosisLastEffect"] = ""


func _on_enemy_basic_attack(origin):
	_on_do_action(player.total_thorns/10, origin, player, "Damage")

	if player.has_meta("BleedReflectPassive"):
		var extra = {"ability" : player.get_meta("BleedReflectAbility")}
		_on_do_action(player.get_meta("BleedReflectPassive"), origin, player, "Bleed", extra)
	
	if player.has_meta("BurnReflectBuff"):
		var extra = {"ability" : "BurnReflectBuff"}
		_on_do_action(player.get_meta("BurnReflectBuff"), origin, player, "Burn", extra)

func _on_basic_attack(target):
	if player.total_life_steal > 0:
		_on_do_action(player.total_attack_damage * (player.total_life_steal/100.0), player, player, "Heal")

	if extra_effect_values.has("Ferver"):
		if target != extra_effect_values["FerverCurrentTarget"]:
			extra_effect_values["FerverCurrentStacks"] = 1
		var extra = {"ability" : extra_effect_values["FerverAbility"]}
		_on_do_action((extra_effect_values["Ferver"]) * extra_effect_values["FerverCurrentStacks"], player, player, "AttackSpeedPassive", extra)
		extra_effect_values["FerverCurrentStacks"] += 1
		extra_effect_values["FerverCurrentTarget"] = target
		if extra_effect_values["FerverCurrentStacks"] > extra_effect_values["FerverMaximumStacks"]:
			extra_effect_values["FerverCurrentStacks"] = extra_effect_values["FerverMaximumStacks"]
	if extra_effect_values.has("RelentlessPrecision"):
		extra_effect_values["RelentlessPrecisionCurrent"] += 1
		if extra_effect_values["RelentlessPrecisionCurrent"] >= extra_effect_values["RelentlessPrecisionInterval"]:
			extra_effect_values["RelentlessPrecisionCurrent"] = 0
			player.get_node("Control").added_extra["Forced Critical"] = true
			player.get_node("Control").added_extra["Forced Critical Amount"] = 1
	if extra_effect_values.has("CrimsonReckoning"):
		extra_effect_values["CrimsonReckoningCurrent"] += 1
		if extra_effect_values["CrimsonReckoningCurrent"] >= extra_effect_values["CrimsonReckoningInterval"]:
			extra_effect_values["CrimsonReckoningCurrent"] = 0
			_on_do_action(player.total_health * (extra_effect_values["CrimsonReckoning"]/100), target, player, "Damage")
			_on_do_action(player.total_health * (extra_effect_values["CrimsonReckoning"]/100), player, player, "Damage")
	if extra_effect_values.has("CrimsonSalvation"):
		extra_effect_values["CrimsonSalvationCurrent"] += 1
		if extra_effect_values["CrimsonSalvationCurrent"] >= extra_effect_values["CrimsonSalvationInterval"]:
			extra_effect_values["CrimsonSalvationCurrent"] = 0
			_on_do_action((player.total_health * 0.05) + extra_effect_values["CrimsonSalvationCurrent"], player, player, "Heal")
	if poison_effect_values.has("PoisonAttack"):
		if _chance_calculator(poison_effect_values["PoisonAttack"]):
			_on_do_action(_spell_scaling(player, poison_effect_values["PoisonAttack"]), target, player, "Poison")
	if bleed_effect_values.has("BleedAttack"):
		if _chance_calculator(bleed_effect_values["BleedAttack"]):
			_on_do_action(_spell_scaling(player, bleed_effect_values["BleedAttack"]/3), target, player, "Bleed")
	if poison_effect_values.has("LuckyPoison") and poisoned_targets.has(player.get_node('Control').attack_target):
			var extra = {"Duration": poison_effect_values["LuckyPoisonDuration"]}
			_on_do_action(poison_effect_values["LuckyPoison"], player, player, "CriticalChanceBuff", extra)
	if bleed_effect_values.has("LuckyBleed") and bleed_targets.has(player.get_node('Control').attack_target):
		var extra = {"Duration": bleed_effect_values["LuckyBleedDuration"]}
		_on_do_action(bleed_effect_values["LuckyBleed"], player, player, "CriticalChanceBuff", extra)
	if extra_effect_values.has("ChaosMagic"):
		if timers.has("ChaosMagic") and timers["ChaosMagic"] >= 0:
			return
		timers["ChaosMagic"] = extra_effect_values["ChaosMagicCooldown"]
		var types = [0, 1]
		ability_manager._use_ability_based_on_type(types)

func _handle_movement_penalty_action(target, value, unit):
	if target:
		unit.bonus_speed -= value
		if unit.is_in_group('players'):
			unit._update_stats()
	else:
		unit.bonus_speed += value
		if unit.is_in_group('players'):
			unit._update_stats()

func _handle_movement_penalty_buff_action(target, value):
	target.get_node('Control').ranged_movement_penalty = 1.0
	target.get_node('Control').melee_movement_penalty = 1.0
	var timer = Utility.get_node('TimerCreator')._create_timer(value, false, target)
	timer.timeout.connect(_deapply_movement_penalty_buff.bind(target))
	timer.start()

func _deapply_movement_penalty_buff(target):
	target.get_node('Control').ranged_movement_penalty = 0.5
	target.get_node('Control').melee_movement_penalty = 0.6

func _handle_movement_charges_action(value, unit):
	unit.charges += value

func _handle_ability_percent_cooldown_reduction_action(unit, value):
		unit.cooldown = unit.cooldown * (1 - value/100.0)

func _handle_wind_speed_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_WindSpeed"
	var new_value = target.total_speed * (value/100.0)
	if target.has_meta('WindSpeedPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('WindSpeedPassive'):
		target.set_meta('WindSpeedPassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('WindSpeedPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('WindSpeedPassive', target.get_meta('WindSpeedPassive') - old_passive)
		target.set_meta('WindSpeedPassive', target.get_meta('WindSpeedPassive') + new_value)
		target.bonus_attack_damage -= old_passive
	
	target.set_meta(ability_name_clean, new_value)
	target.bonus_attack_damage += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_arcane_damage_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_ArcaneDamage"
	var new_value = target.total_intelligence * (value/100.0)
	if target.has_meta('ArcaneDamagePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('ArcaneDamagePassive'):
		target.set_meta('ArcaneDamagePassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('ArcaneDamagePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('ArcaneDamagePassive', target.get_meta('ArcaneDamagePassive') - old_passive)
		target.set_meta('ArcaneDamagePassive', target.get_meta('ArcaneDamagePassive') + new_value)
		target.bonus_attack_damage -= old_passive
	
	target.set_meta(ability_name_clean, new_value)
	target.bonus_attack_damage += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()
		

func _handle_freeze_amount_action(target, value, unit):
	if target:
		if frozen_effect_values.has("FreezeAmount"):
			frozen_effect_values["FreezeAmount"] += value
		else:
			frozen_effect_values["FreezeAmount"] = value
	else:
		frozen_effect_values["FreezeAmount"] -= value
		if frozen_effect_values["FreezeAmount"] <= 0:
			frozen_effect_values.erase("FreezeAmount")

func _handle_last_stand_action(unit, target, value):
	if target:
		extra_effect_values["LastStand"] = value
		extra_effect_values["LastStandCurrent"] = unit.bonus_cooldown_reduction
		unit.bonus_cooldown_reduction = 80
		unit.is_rooted = true
	else:
		extra_effect_values.erase("LastStand")
		unit.bonus_cooldown_reduction = extra_effect_values["LastStandCurrent"]
		unit.is_rooted = false

func _handle_dread_warden_action(unit, target, value):
	if target:
		extra_effect_values["DreadWarden"] = unit.bonus_attack_speed
		extra_effect_values["DreadWardenCurrent"] = unit.base_windup_time
		extra_effect_values["DreadWardenValue"] = value
		unit.global_attack_damage += extra_effect_values["DreadWarden"]
		unit.base_windup_time = value
	else:
		unit.base_windup_time = extra_effect_values["DreadWardenCurrent"]
		unit.global_attack_damage -= extra_effect_values["DreadWarden"]
		extra_effect_values.erase("DreadWarden")

func _handle_elemental_symbiosis_action(target, value, extra):
	if target:
		if !extra_effect_values.has("ElementalSymbiosis"):
			extra_effect_values["ElementalSymbiosis"] = value
			extra_effect_values["ElementalSymbiosisLastEffect"] = ""
			extra_effect_values["ElementalSymbiosisCurrentStack"] = 0
			extra_effect_values["ElementalSymbiosisMaximumStack"] = 4
	else:
		extra_effect_values.erase("ElementalSymbiosis")
		extra_effect_values.erase("ElementalSymbiosisLastEffect")
		extra_effect_values.erase("ElementalSymbiosisCurrentStack")
		extra_effect_values.erase("ElementalSymbiosisMaximumStack")

func _handle_survival_action(unit, target, value):
	if target:
		extra_effect_values["Survival"] = value
		unit.bonus_life_steal += value
		var timer2 = Utility.get_node('TimerCreator')._create_timer(1, true, unit)
		timer2.timeout.connect(_handle_survival_debuff.bind(unit, unit.total_health * 0.03))
		timer2.start()
	else:
		extra_effect_values.erase("Survival")
		unit.bonus_life_steal += value

func _handle_chronos_blessing_action(target, value, unit):
	if target:
		if extra_effect_values.has("ChronosBlessing"):
			extra_effect_values["ChronosBlessing"] += value
			if unit.is_in_group('players'):
				unit.bonus_cooldown_reduction += value
				unit._update_stats()
		else:
			extra_effect_values["ChronosBlessing"] = value
			if unit.is_in_group('players'):
				unit.bonus_cooldown_reduction += value
				unit._update_stats()
	else:
		extra_effect_values["ChronosBlessing"] -= value
		if unit.is_in_group('players'):
			unit.bonus_cooldown_reduction -= value
			unit._update_stats()
		if extra_effect_values["ChronosBlessing"] <= 0:
			extra_effect_values.erase("ChronosBlessing")

func _handle_self_target_action(unit, user):
	if unit.is_in_group('players'):
		user.additional_self_target = true

func _handle_attack_speed_buff_action(target, value, extra):
	var timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "AttackSpeed"))
	timer.start()
	target.bonus_attack_speed += value

func _handle_flat_armor_buff_action(target, value, extra):
	var timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "FlatArmor"))
	timer.start()
	target.bonus_armor += value

func _handle_flat_armor_debuff_action(target, value, extra):
	var timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, -value, "FlatArmor"))
	timer.start()
	target.bonus_armor -= value

func _handle_affliction_buff_action(target, value, extra):
	var timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Affliction"))
	timer.start()
	target.bonus_affliction_resistance += value

func _handle_adrenaline_rush_action(target, user, value, extra):
	_on_do_action(value, target, user, "PercentDamageBuff", extra)
	_on_do_action(20, user, user, "Weaken", extra)

func _handle_rage_regen_buff_action(target, value, extra):
	var timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "RageRegen"))
	timer.start()
	target.rage_regen += value

func _handle_evade_buff_action(target, value, extra):
	var timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Evade"))
	timer.start()
	target.bonus_evade += value

func _handle_flat_thorns_buff_action(target, value, extra):
	var timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Thorns"))
	timer.start()
	target.bonus_thorns += value


func _handle_converganace_action(unit, value, target):
	var reduced_amount
	if extra_effect_values.has("Convergance"):
		reduced_amount = extra_effect_values["Convergance"] + unit.bonus_range
	else:
		reduced_amount = unit.bonus_range
		
	if target:
		if extra_effect_values.has("Convergance"):
			unit.global_attack_damage -= extra_effect_values["Convergance"] / 2.0

		unit.bonus_range = 0
		extra_effect_values["Convergance"] = reduced_amount
		unit.global_attack_damage += (reduced_amount/2.0)
		unit._update_stats()
	else:
		unit.global_attack_damage -= extra_effect_values["Convergance"] / 2.0
		unit.bonus_range = extra_effect_values["Convergance"] + unit.bonus_range
		extra_effect_values.erase("Convergance")
		unit._update_stats()

func _handle_survival_debuff(unit, value):
	if !unit.in_combat:
		var timer = Utility.get_node('TimerCreator')._create_timer(1, true, unit)
		timer.timeout.connect(_handle_survival_debuff.bind(unit, unit.total_health * 0.03))
		timer.start()
		return
	unit.current_health -= value
	
	if unit.current_health <= 0:
		unit.current_health = 0
		_check_if_dead(unit)
	if extra_effect_values.has("Survival"):
		var timer = Utility.get_node('TimerCreator')._create_timer(1, true, unit)
		timer.timeout.connect(_handle_survival_debuff.bind(unit, unit.total_health * 0.03))
		timer.start()
		_trigger_combat_text(unit, unit.total_health * 0.03, 'wheat')

func _handle_summon_flat_health_action(value, _ability):
	_ability.summon_extra_flat_health += value

func _handle_summon_percentage_health_action(value, _ability):
	_ability.summon_extra_percentage_health += value

func _handle_summon_flat_attack_damage_action(value, _ability):
	_ability.summon_extra_flat_attack_damage += value

func _handle_summon_percentage_attack_damage_action(value, _ability):
	_ability.summon_extra_percentage_attack_damage += value

func _handle_summon_flat_armor_action(value, _ability):
	_ability.summon_extra_flat_armor += value

func _handle_summon_percentage_armor_action(value, _ability):
	_ability.summon_extra_percentage_armor += value

func _handle_summon_flat_attack_speed_action(value, _ability):
	_ability.summon_extra_flat_attack_speed += value

func _handle_summon_flat_evade_action(value, _ability):
	_ability.summon_extra_flat_evade += value

func _handle_summon_percentage_evade_action(value, _ability):
	_ability.summon_extra_percentage_evade += value

func _handle_summon_ability_action(_ability, extra):
	_ability.summon_extra_abilities.append(extra["SummonAbility"])

func _handle_cascade_refresh_action(target, value):
	pass # TODO - hitting multiple enemies with area spell reduces remaining cooldown by 50%

func _handle_burn_duration_action(target, value, user):
	if target:
		if burn_effect_values.has("BurnDuration"):
			burn_effect_values["BurnDuration"] += value
		else:
			burn_effect_values["BurnDuration"] = value
	else:
		burn_effect_values["BurnDuration"] -= value
		if burn_effect_values["BurnDuration"] <= 0:
			burn_effect_values.erase("BurnDuration")

func _handle_burn_percent_damage_action(target, value, user):
	if target:
		if burn_effect_values.has("BurnPercentDamage"):
			burn_effect_values["BurnPercentDamage"] += value
		else:
			burn_effect_values["BurnPercentDamage"] = value
	else:
		burn_effect_values["BurnPercentDamage"] -= value
		if burn_effect_values["BurnPercentDamage"] <= 0:
			burn_effect_values.erase("BurnPercentDamage")

func _handle_vampirical_heal_action(target, value):
	if target:
		if extra_effect_values.has("VampiricalHeal"):
			extra_effect_values["VampiricalHeal"] += value
		else:
			extra_effect_values["VampiricalHeal"] = value
	else:
		extra_effect_values["VampiricalHeal"] -= value
		if extra_effect_values["VampiricalHeal"] <= 0:
			extra_effect_values.erase("VampiricalHeal")

func _handle_mana_shield_action(enabled, value, extra):
	if enabled:
		extra_effect_values["ManaShield"] = value
		extra_effect_values["ManaShieldAbility"] = extra['ability']
	else:
		extra_effect_values.erase("ManaShield")
		extra_effect_values.erase("ManaShieldAbility")

func _handle_crimson_reckoning_action(enabled, value, extra):
	if enabled:
		extra_effect_values["CrimsonReckoning"] = value
		extra_effect_values["CrimsonReckoningInterval"] = extra['interval']
		if !extra_effect_values.has("CrimsonReckoningCurrent"):
			extra_effect_values["CrimsonReckoningCurrent"] = 0
	else:
		extra_effect_values.erase("CrimsonReckoning")
		extra_effect_values.erase("CrimsonReckoningInterval")
		extra_effect_values.erase("CrimsonReckoningCurrent")

func _handle_crimson_salvation_action(enabled, value, extra):
	if enabled:
		extra_effect_values["CrimsonSalvation"] = value
		extra_effect_values["CrimsonSalvationInterval"] = extra['interval']
		if !extra_effect_values.has("CrimsonSalvationCurrent"):
			extra_effect_values["CrimsonSalvationCurrent"] = 0
	else:
		extra_effect_values.erase("CrimsonSalvation")
		extra_effect_values.erase("CrimsonSalvationInterval")
		extra_effect_values.erase("CrimsonSalvationCurrent")

func _handle_relentless_precision_action(enabled, value, extra):
	if enabled:
		extra_effect_values["RelentlessPrecision"] = value
		extra_effect_values["RelentlessPrecisionInterval"] = extra['interval']
		if !extra_effect_values.has("RelentlessPrecisionCurrent"):
			extra_effect_values["RelentlessPrecisionCurrent"] = 0
	else:
		extra_effect_values.erase("RelentlessPrecision")
		extra_effect_values.erase("RelentlessPrecisionInterval")
		extra_effect_values.erase("RelentlessPrecisionCurrent")

func _handle_strength_stat_conversion_action(enabled, value, extra):
	if enabled:
		extra_effect_values["StrengthStatConversion"] = value
		extra_effect_values["StrengthStatConversionAbility"] = extra['ability']
	else:
		extra_effect_values.erase("StrengthStatConversion")
		extra_effect_values.erase("StrengthStatConversionAbility")
		_on_do_action(0, player, player, "DexterityToStrengthConversion", extra)
		_on_do_action(0, player, player, "IntelligenceToStrengthConversion", extra)

func _handle_dexterity_stat_conversion_action(enabled, value, extra):
	if enabled:
		extra_effect_values["DexterityStatConversion"] = value
		extra_effect_values["DexterityStatConversionAbility"] = extra['ability']
	else:
		extra_effect_values.erase("DexterityStatConversion")
		extra_effect_values.erase("DexterityStatConversionAbility")
		_on_do_action(0, player, player, "StrengthToDexterityConversion", extra)
		_on_do_action(0, player, player, "IntelligenceToDexterityConversion", extra)

func _handle_intelligence_stat_conversion_action(enabled, value, extra):
	if enabled:
		extra_effect_values["IntelligenceStatConversion"] = value
		extra_effect_values["IntelligenceStatConversionAbility"] = extra['ability']
	else:
		extra_effect_values.erase("IntelligenceStatConversion")
		extra_effect_values.erase("IntelligenceStatConversionAbility")
		_on_do_action(0, player, player, "StrengthToIntelligenceConversion", extra)
		_on_do_action(0, player, player, "DexterityToIntelligenceConversion", extra)

func _handle_ferver_action(enabled, value, extra):
	if enabled:
		extra_effect_values["Ferver"] = value
		extra_effect_values["FerverMaximumStacks"] = 10
		extra_effect_values["FerverAbility"] = extra['ability']
		if !extra_effect_values.has("FerverCurrentStacks"):
			extra_effect_values["FerverCurrentStacks"] = 1
			extra_effect_values["FerverCurrentTarget"] = null
	else:
		extra_effect_values.erase("Ferver")
		extra_effect_values.erase("FerverMaximumStacks")
		extra_effect_values.erase("FerverCurrentStacks")
		extra_effect_values.erase("FerverCurrentTarget")
		extra_effect_values.erase("FerverAbility")

func _handle_burn_heal_action(target, value):
	if target:
		if burn_effect_values.has("BurnHeal"):
			burn_effect_values["BurnHeal"] += value
		else:
			burn_effect_values["BurnHeal"] = value
	else:
		burn_effect_values["BurnHeal"] -= value
		if burn_effect_values["BurnHeal"] <= 0:
			burn_effect_values.erase("BurnHeal")

func _handle_frozen_quick_attack_action(target, value):
	if target:
		if frozen_effect_values.has("FrozenQuickAttack"):
			frozen_effect_values["FrozenQuickAttack"] += value
		else:
			frozen_effect_values["FrozenQuickAttack"] = value
	else:
		frozen_effect_values["FrozenQuickAttack"] -= value
		if frozen_effect_values["FrozenQuickAttack"] <= 0:
			frozen_effect_values.erase("FrozenQuickAttack")

func _handle_frozen_chance_action(target, value, unit):
	if target:
		if frozen_effect_values.has("FrozenChance"):
			frozen_effect_values["FrozenChance"] += value
		else:
			frozen_effect_values["FrozenChance"] = value
	else:
		frozen_effect_values["FrozenChance"] -= value
		if frozen_effect_values["FrozenChance"] <= 0:
			frozen_effect_values.erase("FrozenChance")

func _handle_poison_attack_action(target, value):
	if target:
		if poison_effect_values.has("PoisonAttack"):
			poison_effect_values["PoisonAttack"] += value
		else:
			poison_effect_values["PoisonAttack"] = value
	else:
		poison_effect_values["PoisonAttack"] -= value
		if poison_effect_values["PoisonAttack"] <= 0:
			poison_effect_values.erase("PoisonAttack")

func _handle_bleed_attack_action(target, value):
	if target:
		if bleed_effect_values.has("BleedAttack"):
			bleed_effect_values["BleedAttack"] += value
		else:
			bleed_effect_values["BleedAttack"] = value
	else:
		bleed_effect_values["BleedAttack"] -= value
		if bleed_effect_values["BleedAttack"] <= 0:
			bleed_effect_values.erase("BleedAttack")

func _handle_lucky_poison_action(target, value, extra):
	if target:
		if poison_effect_values.has("LuckyPoison"):
			poison_effect_values["LuckyPoison"] += value
		else:
			poison_effect_values["LuckyPoison"] = value
		poison_effect_values["LuckyPoisonDuration"] = extra['Duration']
	else:
		poison_effect_values["LuckyPoison"] -= value
		if poison_effect_values["LuckyPoison"] <= 0:
			poison_effect_values.erase("LuckyPoison")
			poison_effect_values.erase("LuckyPoisonDuration")

func _handle_lucky_bleed_action(target, value, extra):
	if target:
		if bleed_effect_values.has("LuckyBleed"):
			bleed_effect_values["LuckyBleed"] += value
		else:
			bleed_effect_values["LuckyBleed"] = value
		bleed_effect_values["LuckyBleedDuration"] = extra['Duration']
	else:
		bleed_effect_values["LuckyBleed"] -= value
		if bleed_effect_values["LuckyBleed"] <= 0:
			bleed_effect_values.erase("LuckyBleed")
			bleed_effect_values.erase("LuckyBleedDuration")

func _handle_low_health_invincible_action(extra, value):
	if extra["Effect"]:
		if !extra_effect_values.has("LowHealthInvincible"):
			extra_effect_values["LowHealthInvincible"] = value
			extra_effect_values["LowHealthInvincibleCooldown"] = 0
	else:
		extra_effect_values.erase("LowHealthInvincible")
		extra_effect_values.erase("LowHealthInvincibleCooldown")

func _handle_chaos_magic_action(target, value, extra):
	if target:
		if extra_effect_values.has("ChaosMagic"):
			extra_effect_values["ChaosMagic"] += value
		else:
			extra_effect_values["ChaosMagic"] = value
		extra_effect_values["ChaosMagicCooldown"] = extra['Cooldown']
		if !timers.has("ChaosMagic"):
			timers["ChaosMagic"] = extra['Cooldown']
	else:
		extra_effect_values.erase("ChaosMagic")
		extra_effect_values.erase("ChaosMagicCooldown")
		timers.erase("ChaosMagic")

func _handle_frozen_percentage_damage_buff_action(target, value):
	if target:
		if frozen_effect_values.has("FrozenPercentageDamageBuff"):
			frozen_effect_values["FrozenPercentageDamageBuff"] += value
		else:
			frozen_effect_values["FrozenPercentageDamageBuff"] = value
	else:
		frozen_effect_values["FrozenPercentageDamageBuff"] -= value
		if frozen_effect_values["FrozenPercentageDamageBuff"] <= 0:
			frozen_effect_values.erase("FrozenPercentageDamageBuff")
# Triggers the effects of a combat action on the target.
# Parameters:
# - target: The target of the combat action.
# - damage: The amount of damage dealt.
# - color: The color of the combat text.
func _trigger_effects(target, damage, color, tag):
	_trigger_combat_text(target, damage, color)
	if color != 'green':
		_trigger_hit_effect(target, tag)

func _handle_boost_mana_regen_action(target, value, unit):
	var timer = Utility.get_node('TimerCreator')._create_timer(target, true, unit)
	timer.timeout.connect(_deapply_buff.bind(unit, value, "ManaRegen"))
	unit.bonus_mana_regen += value
	timer.start()

func _handle_boost_mana_regen_percent_action(target, value, unit):
	var timer = Utility.get_node('TimerCreator')._create_timer(target, true, unit)
	timer.timeout.connect(_deapply_global_buff.bind(unit, value, "ManaRegen"))
	unit.global_mana_regen += value
	timer.start()

# Handles experience gain for the player.
# Parameters:
# - target: The target of the experience gain.
# - value: The amount of experience to gain.
func _handle_experience_action(_target, value):
	_trigger_combat_text(player, value, 'Purple')
	if player.is_in_group('players'):
		player.total_ability_experience += value/2
		player.current_player_experience += value/2

# Handles ascension currency gain for the player.
# Parameters:
# - target: The target of the ascension currency gain.
# - value: The amount of ascension currency to gain.
func _handle_ascension_action(_target, value):
	if player.is_in_group('players'):
		player.ascension_currency += value

# Handles the pierce action for the user.
# Parameters:
# - user: The user of the action.
func _handle_pierce_action(user):
	user.line_pierce = true

func _handle_ricochet_action(user, amount):
	user.projectile_ricochet = true
	user.projectile_ricochet_amount += amount

func _handle_split_action(user, amount):
	user.projectile_split = true
	user.projectile_split_amount += amount

func _handle_swap_action(user):
	user.swap_position = true

func _handle_root_action(target, value):
	if target.is_in_group('boss'):
		return
	target.is_rooted = true
	var timer = Utility.get_node('TimerCreator')._create_timer(value, true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Root"))
	timer.start()
	var effect = root_effect.instantiate()
	effect.name = "Root_effect"
	target.add_child(effect)

func _handle_stun_action(target, value):
	if target.is_in_group('boss'):
		return
	target.is_stunned = true
	var timer = Utility.get_node('TimerCreator')._create_timer(value, true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Stun"))
	timer.start()
	var effect = stun_effect.instantiate()
	effect.name = "Stun_effect"
	target.add_child(effect)

func _handle_taunt_action(target, value, user):
	if target.is_in_group('boss'):
		return
	target.is_taunted = true
	target.taunted_target = user
	var timer = Utility.get_node('TimerCreator')._create_timer(value, true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Taunt"))
	timer.start()
	var effect = taunt_effect.instantiate()
	effect.name = "Taunt_effect"
	target.add_child(effect)

func _handle_umbral_snare_action(target, value, user, extra):
	if target.global_position.distance_to(user.global_position) < 100:
		_on_do_action(value, target, user, "Freeze", extra)
	_on_do_action(150, target, user, "GravityPull")

func _handle_execute_action(target, value, user):
	if target in invincible_units or _check_if_dead(target) or target.is_in_group('boss'):
		return
	if target.current_health <= target.total_health * (value/100.0):
		target.current_health = 0
		_trigger_combat_text(user, target.total_health, 'Execute')

func _handle_detonate_burn_action(target, value, user):
	var burn_nodes = []
	for nodes in target.get_children():
		if "burn" in nodes.name or "Burn" in nodes.name:
			burn_nodes.append(nodes)
	
	if burn_nodes.size() > 0:
		for node in burn_nodes:
			_on_do_action(value, target, user, "Damage")
			node.queue_free()

# Handles the refunding of mana.
# Parameters:
# - target: The target of the mana refund.
# - value: The amount of mana to refund.
func _handle_refund_mana_action(target, value, extra):
	if target.is_in_group('players'):
		target.current_mana += extra.mana_cost * (value/100)
		if target.current_mana > target.total_mana:
			target.current_mana = target.total_mana
		_trigger_combat_text(target, extra.mana_cost * (value/100), 'blue')

func _handle_reduce_cooldowns_action(target, value, extra):
	if target.is_in_group('players'):
		for _ability in target.get_node("InventoryManager").abilities:
			if _ability.cooldown > 0:
				_ability._reduce_cooldown(value)

# Spell scaling based on main stat
# Parameters:
# - user: The user of the action.
# - value: The value to scale the spell with.
func _spell_scaling(user, value):
	if user.type.find("INT") != -1:
		return (0.3*user.total_intelligence) * value
	if user.type.find("STR") != -1:
		return (0.3*user.total_strength) * value
	if user.type.find("DEX") != -1:
		return (0.3*user.total_dexterity) * value

func _handle_crit_chance_buff_action(target, value, extra):
	if target.is_in_group('players'):
		target.bonus_critical_chance += value
		target._update_stats()
		var timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
		timer.timeout.connect(_deapply_buff.bind(target, value, "CriticalChance"))
		timer.start()

func _handle_burn_reflect_buff_action(target, value, extra):
	if target.is_in_group('players'):
		if target.has_meta("BurnReflectBuff"):
			target.set_meta("BurnReflectBuff", target.get_meta("BurnReflectBuff") + value)
		else:
			target.set_meta("BurnReflectBuff", value)
		target._update_stats()
		var timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
		timer.timeout.connect(_deapply_buff.bind(target, value, "BurnReflect"))
		timer.start()


# Handles the damaging teleport action for the user.
# Parameters:
# - user: The user of the action.
# - value: The target location of the teleport.
func _handle_damaging_teleport_action(user, value):
	var teleport_location = map_manager._get_random_walkable_tile()
	var damage = _spell_scaling(user, 10)
	var targets = []
	await get_tree().create_timer(0.1).timeout
	user.global_position = teleport_location
	for i in get_tree().get_nodes_in_group("enemies"):
		if i.global_position.distance_to(teleport_location) < 100:
			targets.append(i)
	for i in targets:
		_on_do_action(damage, i, user, "Damage")

func _handle_explosion_action(user, value):
	user.explosion = true
	user.explosion_radius = value

func _handle_burn_explosion_action(target, value, radius, unit):
	if target:
		if burn_effect_values.has("BurnExplosion" + str(unit)):
			burn_effect_values["BurnExplosion" + str(unit)] += value
			burn_effect_values["BurnExplosionRadius" + str(unit)] += radius
		else:
			burn_effect_values["BurnExplosion" + str(unit)] = value
			burn_effect_values["BurnExplosionRadius" + str(unit)] = radius
			timers["BurnExplosion" + str(unit)] = value
	else:
		burn_effect_values["BurnExplosion" + str(unit)] -= value
		burn_effect_values["BurnExplosionRadius" + str(unit)] -= radius
		if burn_effect_values["BurnExplosion" + str(unit)] <= 0:
			burn_effect_values.erase("BurnExplosion" + str(unit))
			burn_effect_values.erase("BurnExplosionRadius" + str(unit))
			timers.erase("BurnExplosion" + str(unit))
# Handles the duplicate action for the user.
# Parameters:
# - user: The user of the action.
# - value: The value to add to the user's amount.
func _handle_duplicate_action(user, value):
	if user.projectile_type != 0:
		return
	user.amount += value

func _handle_multistrike_action(target, value, user):
	user.additional_targets += value

func _handle_area_pool_action(user, value, extra):
	user.area_pool = true
	user.area_pool_radius = value

func _handle_echo_action(user, value):
	user.echo += value

func _handle_projectile_speed_action(user, value):
	user.speed += value

func _handle_area_radius_action(user, value):
	user.radius += value

func _handle_passive_activate_action(user, value):
	user.activatable = true
	user.activatable_duration = value
	user.activatable_cooldown = 40

func _handle_ability_percent_damage_action(user, value):
	user.added_percentage_damage += value/100.0

func _handle_cooldown_reset_on_kill_action(target, extra):
	var total_damage = 0
	for t in extra["ability_instance"].tags:
		if "Damage" in t:
			total_damage += extra["ability_instance"].values[extra["ability_instance"].tags.find(t)]
	
	if _check_if_kills(target, total_damage):
		extra["ability_instance"]._reset_cooldown()

func _handle_bleed_stack_consume_heal_action(target, value, user, extra):
	if target.has_meta("Bleed_stacks"):
		var stacks = target.get_meta("Bleed_stacks")
		_on_do_action(value * stacks, user, target, "PercentHeal", extra)
		target.set_meta("Bleed_stacks", 0)

func _handle_freeze_extra_flat_damage_action(target, value):
	if target.has_node("Freeze_timer"):
		_on_do_action(value, target, player, "Damage")

func _handle_poison_extra_stack_action(target, value):
	if target.has_node("Poison_timer"):
		_on_do_action(value, target, player, "Poison")

func _handle_crowd_control_extra_flat_damage_action(target, value):
	if target.is_stunned or target.is_rooted:
		_on_do_action(value, target, player, "Damage")

func _handle_stun_extra_flat_damage_action(target, value):
	if target.is_stunned:
		_on_do_action(value, target, player, "Damage")
# Handles the modifier action for the user.
# Parameters:
# - user: The user of the action.
# - target: The target of the action.
func _handle_modifier_action(user, target, extra = null):
	if user.is_in_group('players'):
		var modifiers = user.current_attack_modifier_tags
		var values = user.current_attack_modifier_values
		user.get_node('Control').basic_attacking.emit(target)
		for i in range(modifiers.size()):
			_on_do_action(values[i], target, user, modifiers[i], extra)


func _handle_basic_attack_damage_action(target, value, user):
	if user.is_in_group('players'):
		_on_do_action(user.total_attack_damage * (value/100.0), target, user, "Damage")
# Handles the damage action on the target.
# Parameters:
# - target: The target of the action.
# - damage: The amount of damage to deal.
func _handle_damage_action(target, damage, tag, user, extra = {"basic_attacking": false, "critical": false}):
	if target in invincible_units:	
		return

	if target.has_meta("Weaken_amount"):
		damage += damage * (target.get_meta("Weaken_amount")/100.0)

	if extra == null:
		extra = {"basic_attacking": false, "critical": false}
	
	var new_damage = _apply_shock(target, _apply_global_protection_passives(damage, user))
	if target.is_in_group('players'):
		new_damage -= target.total_block
		if extra_effect_values.has("ManaShield"):
			var potential_damage = new_damage * (1 - extra_effect_values["ManaShield"]/100.0)
			var mana_damage = float(new_damage - potential_damage)
			if target.current_mana >= mana_damage:
				target.current_mana -= mana_damage
				new_damage = potential_damage
			else:
				new_damage -= target.current_mana
				target.current_mana = 0

	# Effects:
	if !target.is_in_group('players'):
		if target.is_frozen:
			if frozen_effect_values.has("FrozenPercentageDamageBuff"):
				new_damage += new_damage *(1 + frozen_effect_values["FrozenPercentageDamageBuff"]/100.0)
	
	var rest_damage = _barrier_protection(target, new_damage)
	if rest_damage == 0:
		return
	target.current_health -= rest_damage
	if extra.has("basic_attacking") and extra["basic_attacking"]:
		if extra_effect_values.has("VampiricalHeal"):
			_on_do_action(float(player.total_attack_damage * (extra_effect_values["VampiricalHeal"]/100.0)), player, player, "Heal")
	if extra.has('critical') and extra["critical"]:
		_trigger_effects(target, rest_damage, 'yellow', tag)
	else:
		_trigger_effects(target, rest_damage, 'Wheat', tag)
	if target.has_node('Shock_timer'):
		await get_tree().create_timer(0.1).timeout
		if _check_if_dead(target):
			return
		_trigger_combat_text(target, 10 * target.get_meta('Shock_count'), 'goldenrod')

# Handles the attack range passive on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack range passive.
func _handle_attack_range_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_AttackRange"
	if target.has_meta('AttackRangePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('AttackRangePassive'):
		target.set_meta('AttackRangePassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('AttackRangePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('AttackRangePassive', target.get_meta('AttackRangePassive') - old_passive)
		target.set_meta('AttackRangePassive', target.get_meta('AttackRangePassive') + value)
		target.bonus_range -= old_passive
	
	target.set_meta(ability_name_clean, value)
	target.bonus_range += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_bleed_reflect_action(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_BleedReflect"
	if target.has_meta('BleedReflectPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('BleedReflectPassive'):
		target.set_meta('BleedReflectPassive', value)
		target.set_meta("BleedReflectAbility", ability_name_clean)

	if target.has_meta(ability_name_clean) and target.has_meta('BleedReflectPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('BleedReflectPassive', target.get_meta('BleedReflectPassive') - old_passive)
		target.set_meta('BleedReflectPassive', target.get_meta('BleedReflectPassive') + value)

	target.set_meta(ability_name_clean, value)

func _handle_spell_vamp_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_SpellVamp"
	if target.has_meta('SpellVampPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('SpellVampPassive'):
		target.set_meta('SpellVampPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('SpellVampPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('SpellVampPassive', target.get_meta('SpellVampPassive') - old_passive)
		target.set_meta('SpellVampPassive', target.get_meta('SpellVampPassive') + value)
		target.bonus_spell_vamp -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_spell_vamp += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_strength_to_vitality_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_StrengthToVitality"
	var new_value = target.total_strength * (value/100.0)
	if target.has_meta('StrengthToVitalityPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('StrengthToVitalityPassive'):
		target.set_meta('StrengthToVitalityPassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('StrengthToVitalityPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('StrengthToVitalityPassive', target.get_meta('StrengthToVitalityPassive') - old_passive)
		target.set_meta('StrengthToVitalityPassive', target.get_meta('StrengthToVitalityPassive') + new_value)
		target.bonus_vitality -= old_passive

	target.set_meta(ability_name_clean, new_value)
	target.bonus_vitality += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_strength_to_dexterity_conversion(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_StrengthToDexterity"
	var left_over = 0
	var new_value = target.total_strength * (value/100.0)
	if value > 100:
		left_over = new_value - target.total_strength
	if target.has_meta('StrengthToDexterityPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('StrengthToDexterityPassive'):
		target.set_meta('StrengthToDexterityPassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('StrengthToDexterityPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('StrengthToDexterityPassive', target.get_meta('StrengthToDexterityPassive') - old_passive)
		target.set_meta('StrengthToDexterityPassive', target.get_meta('StrengthToDexterityPassive') + new_value)
		target.bonus_dexterity -= old_passive
		target.bonus_strength += old_passive - left_over

	target.set_meta(ability_name_clean, new_value)
	target.bonus_dexterity += target.get_meta(ability_name_clean)
	target.bonus_strength -= target.get_meta(ability_name_clean) - left_over
	if target.is_in_group('players'):
		target._update_stats()

func _handle_strength_to_intelligence_conversion(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_StrengthToIntelligence"
	var left_over = 0
	var new_value = target.total_strength * (value/100.0)
	if value > 100:
		left_over = new_value - target.total_strength
	if target.has_meta('StrengthToIntelligencePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('StrengthToIntelligencePassive'):
		target.set_meta('StrengthToIntelligencePassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('StrengthToIntelligencePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('StrengthToIntelligencePassive', target.get_meta('StrengthToIntelligencePassive') - old_passive)
		target.set_meta('StrengthToIntelligencePassive', target.get_meta('StrengthToIntelligencePassive') + new_value)
		target.bonus_intelligence -= old_passive
		target.bonus_strength += old_passive - left_over

	target.set_meta(ability_name_clean, new_value)
	target.bonus_intelligence += target.get_meta(ability_name_clean)
	target.bonus_strength -= target.get_meta(ability_name_clean) - left_over
	if target.is_in_group('players'):
		target._update_stats()

func _handle_dexterity_to_strength_conversion(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_DexterityToStrength"
	var left_over = 0
	var new_value = target.total_dexterity * (value/100.0)
	if value > 100:
		left_over = new_value - target.total_dexterity
	if target.has_meta('DexterityToStrengthPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('DexterityToStrengthPassive'):
		target.set_meta('DexterityToStrengthPassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('DexterityToStrengthPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('DexterityToStrengthPassive', target.get_meta('DexterityToStrengthPassive') - old_passive)
		target.set_meta('DexterityToStrengthPassive', target.get_meta('DexterityToStrengthPassive') + new_value)
		target.bonus_strength -= old_passive
		target.bonus_dexterity += old_passive - left_over

	target.set_meta(ability_name_clean, new_value)
	target.bonus_strength += target.get_meta(ability_name_clean)
	target.bonus_dexterity -= target.get_meta(ability_name_clean) - left_over
	if target.is_in_group('players'):
		target._update_stats()

func _handle_dexterity_to_intelligence_conversion(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_DexterityToIntelligence"
	var left_over = 0
	var new_value = target.total_dexterity * (value/100.0)
	if value > 100:
		left_over = new_value - target.total_dexterity
	if target.has_meta('DexterityToIntelligencePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('DexterityToIntelligencePassive'):
		target.set_meta('DexterityToIntelligencePassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('DexterityToIntelligencePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('DexterityToIntelligencePassive', target.get_meta('DexterityToIntelligencePassive') - old_passive)
		target.set_meta('DexterityToIntelligencePassive', target.get_meta('DexterityToIntelligencePassive') + new_value)
		target.bonus_intelligence -= old_passive
		target.bonus_dexterity += old_passive - left_over

	target.set_meta(ability_name_clean, new_value)
	target.bonus_intelligence += target.get_meta(ability_name_clean)
	target.bonus_dexterity -= target.get_meta(ability_name_clean) - left_over
	if target.is_in_group('players'):
		target._update_stats()

func _handle_intelligence_to_strength_conversion(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_IntelligenceToStrength"
	var left_over = 0
	var new_value = target.total_intelligence * (value/100.0)
	if value > 100:
		left_over = new_value - target.total_intelligence
	if target.has_meta('IntelligenceToStrengthPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('IntelligenceToStrengthPassive'):
		target.set_meta('IntelligenceToStrengthPassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('IntelligenceToStrengthPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('IntelligenceToStrengthPassive', target.get_meta('IntelligenceToStrengthPassive') - old_passive)
		target.set_meta('IntelligenceToStrengthPassive', target.get_meta('IntelligenceToStrengthPassive') + new_value)
		target.bonus_strength -= old_passive
		target.bonus_intelligence += old_passive - left_over

	target.set_meta(ability_name_clean, new_value)
	target.bonus_strength += target.get_meta(ability_name_clean)
	target.bonus_intelligence -= target.get_meta(ability_name_clean) - left_over
	if target.is_in_group('players'):
		target._update_stats()

func _handle_intelligence_to_dexterity_conversion(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_IntelligenceToDexterity"
	var left_over = 0
	var new_value = target.total_intelligence * (value/100.0)
	if value > 100:
		left_over = new_value - target.total_intelligence
	if target.has_meta('IntelligenceToDexterityPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == new_value:
		return

	if !target.has_meta('IntelligenceToDexterityPassive'):
		target.set_meta('IntelligenceToDexterityPassive', new_value)

	if target.has_meta(ability_name_clean) and target.has_meta('IntelligenceToDexterityPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('IntelligenceToDexterityPassive', target.get_meta('IntelligenceToDexterityPassive') - old_passive)
		target.set_meta('IntelligenceToDexterityPassive', target.get_meta('IntelligenceToDexterityPassive') + new_value)
		target.bonus_dexterity -= old_passive
		target.bonus_intelligence += old_passive - left_over

	target.set_meta(ability_name_clean, new_value)
	target.bonus_dexterity += target.get_meta(ability_name_clean)
	target.bonus_intelligence -= target.get_meta(ability_name_clean) - left_over
	if target.is_in_group('players'):
		target._update_stats()

func _handle_dying_breath_action(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean = "_DyingBreath"
	if target.has_meta('DyingBreathPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('DyingBreathPassive'):
		target.set_meta('DyingBreathPassive', value)
	
	if target.has_meta(ability_name_clean) and target.has_meta('DyingBreathPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('DyingBreathPassive', target.get_meta('DyingBreathPassive') - old_passive)
		target.set_meta('DyingBreathPassive', target.get_meta('DyingBreathPassive') + value)
		target.global_damage -= old_passive
	
	target.set_meta(ability_name_clean, value)
	target.global_damage += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_life_steal_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_LifeSteal"
	if target.has_meta('LifeStealPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('LifeStealPassive'):
		target.set_meta('LifeStealPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('LifeStealPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('LifeStealPassive', target.get_meta('LifeStealPassive') - old_passive)
		target.set_meta('LifeStealPassive', target.get_meta('LifeStealPassive') + value)
		target.bonus_life_steal -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_life_steal += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_critical_chance_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_CriticalChance"
	if target.has_meta('CriticalChancePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('CriticalChancePassive'):
		target.set_meta('CriticalChancePassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('CriticalChancePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('CriticalChancePassive', target.get_meta('CriticalChancePassive') - old_passive)
		target.set_meta('CriticalChancePassive', target.get_meta('CriticalChancePassive') + value)
		target.bonus_critical_chance -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_critical_chance += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_critical_damage_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_CriticalDamage"
	if target.has_meta('CriticalDamagePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('CriticalDamagePassive'):
		target.set_meta('CriticalDamagePassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('CriticalDamagePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('CriticalDamagePassive', target.get_meta('CriticalDamagePassive') - old_passive)
		target.set_meta('CriticalDamagePassive', target.get_meta('CriticalDamagePassive') + value)
		target.bonus_critical_damage -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_critical_damage += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_frozen_chance_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_FrozenChance"
	if target.has_meta('FrozenChancePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('FrozenChancePassive'):
		target.set_meta('FrozenChancePassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('FrozenChancePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('FrozenChancePassive', target.get_meta('FrozenChancePassive') - old_passive)
		target.set_meta('FrozenChancePassive', target.get_meta('FrozenChancePassive') + value)
		target.bonus_frozen_chance -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_frozen_chance += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

# Handles the movement speed passive on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the movement speed passive.
func _handle_movement_speed_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_MovementSpeed"
	if target.has_meta('MovementSpeedPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('MovementSpeedPassive'):
		target.set_meta('MovementSpeedPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('MovementSpeedPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('MovementSpeedPassive', target.get_meta('MovementSpeedPassive') - old_passive)
		target.set_meta('MovementSpeedPassive', target.get_meta('MovementSpeedPassive') + value)
		target.bonus_speed -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_speed += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_double_cast_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_DoubleCast"
	if target.has_meta('DoubleCastPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('DoubleCastPassive'):
		target.set_meta('DoubleCastPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('DoubleCastPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('DoubleCastPassive', target.get_meta('DoubleCastPassive') - old_passive)
		target.set_meta('DoubleCastPassive', target.get_meta('DoubleCastPassive') + value)
		target.bonus_double_cast_chance -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_double_cast_chance += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_flat_evade_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_FlatEvade"
	if target.has_meta('FlatEvadePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('FlatEvadePassive'):
		target.set_meta('FlatEvadePassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('FlatEvadePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('FlatEvadePassive', target.get_meta('FlatEvadePassive') - old_passive)
		target.set_meta('FlatEvadePassive', target.get_meta('FlatEvadePassive') + value)
		target.bonus_evade -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_evade += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_flat_thorns_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_FlatThorns"
	if target.has_meta('FlatThornsPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('FlatThornsPassive'):
		target.set_meta('FlatThornsPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('FlatThornsPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('FlatThornsPassive', target.get_meta('FlatThornsPassive') - old_passive)
		target.set_meta('FlatThornsPassive', target.get_meta('FlatThornsPassive') + value)
		target.bonus_thorns -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_thorns += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_quick_attack_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_QuickAttack"
	if target.has_meta('QuickAttackPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('QuickAttackPassive'):
		target.set_meta('QuickAttackPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('QuickAttackPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('QuickAttackPassive', target.get_meta('QuickAttackPassive') - old_passive)
		target.set_meta('QuickAttackPassive', target.get_meta('QuickAttackPassive') + value)
		target.bonus_quick_attack_chance -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_quick_attack_chance += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

# Handles the attack speed passive on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack speed passive.
func _handle_attack_speed_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_AttackSpeed"
	if target.has_meta('AttackSpeedPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('AttackSpeedPassive'):
		target.set_meta('AttackSpeedPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('AttackSpeedPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('AttackSpeedPassive', target.get_meta('AttackSpeedPassive') - old_passive)
		target.set_meta('AttackSpeedPassive', target.get_meta('AttackSpeedPassive') + value)
		target.bonus_attack_speed -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_attack_speed += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_attack_target_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_AttackTarget"
	value = floor(value)
	if target.has_meta('AttackTargetPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('AttackTargetPassive'):
		target.set_meta('AttackTargetPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('AttackTargetPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('AttackTargetPassive', target.get_meta('AttackTargetPassive') - old_passive)
		target.set_meta('AttackTargetPassive', target.get_meta('AttackTargetPassive') + value)
		target.bonus_attack_targets -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_attack_targets += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_protection_passive_action(target, value, tag, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_Protection"
	if target.has_meta(tag) and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return
	
	if !target.has_meta(tag):
		target.set_meta(tag, value)

	if target.has_meta(ability_name_clean) and target.has_meta(tag):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta(tag, target.get_meta(tag) - old_passive)
		target.set_meta(tag, target.get_meta(tag) + value)
		target.bonus_protection -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_protection += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_stealth_action(user, value):
	user.in_stealth = true
	var timer = Utility.get_node('TimerCreator')._create_timer(value, true, user)
	timer.timeout.connect(_deapply_stealth.bind(user))
	timer.start()


func _handle_attack_action(user, times, tags, values):
	if user.is_in_group('players'):
		for i in range(times):
			user.get_node('Control')._attack([], [], 0.0, (user.get_global_mouse_position() - user.global_position).normalized(), 0)
			await get_tree().create_timer(0.3).timeout

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

	print("Poisoned")
	if target.has_meta("Weaken_amount"):
		value += value * (target.get_meta("Weaken_amount")/100.0)

	var duration = 5
	var base_damage = 5
	var added_damage = 0
	if target.is_in_group('players'):
		duration = 5 - ((target.total_affliction_resistance/100.0) * duration)

	if user.is_in_group('players'):
		added_damage += base_damage * (user.global_poison_damage/100.0 + user.global_damage/100.0)
		base_damage += added_damage
	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var damage_per_tick = base_damage / total_ticks 

	if !target.has_node('Poison_timer'):
		target.set_meta('Poison_count', 0)
		target.set_meta('Poison_stacks', value)
		var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)
		var timer_name = "Poison_timer"
		timer.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'green', 'Poison', timer_name))
		timer.name = timer_name
		timer.start()
	else:
		target.set_meta('Poison_stacks', target.get_meta('Poison_stacks') + value)

# Handles the frenzy buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the frenzy buff.
# - user: The duration of the frenzy buff.
func _handle_frenzy_buff_action(target, value, user, extra):
	var duration = 5
	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var damage_per_tick = (target.total_health * 0.25) / total_ticks
	target.bonus_attack_speed += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "AttackSpeed"))
	target.add_child(timer)
	timer.start()
	target.add_child(timer)

	if !target.has_node('Frenzy_timer'):
		var timer2 = Utility.get_node('TimerCreator')._create_timer(1, false, target)
		target.set_meta('Frenzy_count', 0)
		target.set_meta('Frenzy_timer', true)
		timer2.name = "Frenzy_timer"
		timer2.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'salmon', 'Frenzy'))
		target.add_child(timer2)
		timer2.start()
	else:
		target.set_meta('Frenzy_count', 0)

# Handles the percent armor buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the armor buff.
# - user: The user of the action.
func _handle_percent_armor_buff_action(target, value, user, extra):
	target.global_armor += value
	target.set_meta('ArmorBuff', value)
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_global_buff.bind(target, target.get_meta('Armorbuff'), "Armor"))
	timer.start()

func _handle_percent_armor_debuff_action(target, value, user, extra):
	target.bonus_armor -= (value/100.0) * target.total_armor
	target.set_meta('ArmorDebuff', (value/100.0) * target.total_armor)
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, -target.get_meta('ArmorDebuff'), "Armor"))
	timer.start()

# Handles the percent speed buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the speed buff.
# - user: The duration of the action.
func _handle_percent_speed_buff_action(target, value, user, extra):
	target.global_movement_speed += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT or typeof(user) == TYPE_FLOAT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
	timer.timeout.connect(_deapply_global_buff.bind(target, value, "Speed"))
	timer.start()

func _handle_percent_damage_buff_action(target, value, user, extra):
	target.global_damage += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT or typeof(user) == TYPE_FLOAT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
	timer.timeout.connect(_deapply_global_buff.bind(target, value, "Damage"))
	timer.start()

func _handle_percent_health_buff_action(target, value, user, extra):
	target.global_health += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT or typeof(user) == TYPE_FLOAT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
	timer.timeout.connect(_deapply_global_buff.bind(target, value, "Health"))
	timer.start()

func _handle_percent_poison_damage_buff_action(target, value, user, extra):
	target.global_poison_damage += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT or typeof(user) == TYPE_FLOAT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
	timer.timeout.connect(_deapply_global_buff.bind(target, value, "PoisonDamage"))
	timer.start()

func _handle_percent_size_buff_action(target, value, user, extra):
	target.global_size += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT or typeof(user) == TYPE_FLOAT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
	timer.timeout.connect(_deapply_global_buff.bind(target, value, "Size"))
	timer.start()

# Handles the percent attack buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack buff.
# - user: The duration of the action.
func _handle_percent_attack_buff_action(target, value, user, extra):
	target.global_attack_damage += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT or typeof(user) == TYPE_FLOAT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
	timer.timeout.connect(_deapply_global_buff.bind(target, value, "AttackDamage"))
	timer.start()

# Handles the attack buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack buff.
# - user: The user of the action.
# - tag: The tag associated with the attack buff.
func _handle_attack_buff_action(target, value, user, tag, extra):
	if !target.is_in_group('players'):
		return
	target.current_attack_modifier_abilities.append(extra['ability'])
	target.current_attack_modifier_tags.append(tag)
	target.current_attack_modifier_values.append(value)

	var timer
	if typeof(user) == TYPE_INT or typeof(user) == TYPE_FLOAT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra['Duration'], true, target)
		timer.name = tag + "_attack_timer"
	timer.timeout.connect(_deapply_attack_buff.bind(target, value, tag))
	timer.start()

# Handles the attack damage passive on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the attack damage passive.
func _handle_attack_damage_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_AttackDamage"
	if target.has_meta('AttackDamagePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('AttackDamagePassive'):
		target.set_meta('AttackDamagePassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('AttackDamagePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('AttackDamagePassive', target.get_meta('AttackDamagePassive') - old_passive)
		target.set_meta('AttackDamagePassive', target.get_meta('AttackDamagePassive') + value)
		target.bonus_attack_damage -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_attack_damage += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_boost_mana_regen_passive_action(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_ManaRegenBoost"
	if target.has_meta('ManaRegenBoostPassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('ManaRegenBoostPassive'):
		target.set_meta('ManaRegenBoostPassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('ManaRegenBoostPassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('ManaRegenBoostPassive', target.get_meta('ManaRegenBoostPassive') - old_passive)
		target.set_meta('ManaRegenBoostPassive', target.get_meta('ManaRegenBoostPassive') + value)
		target.bonus_mana_regen -= old_passive

	target.set_meta(ability_name_clean, value)
	target.bonus_mana_regen += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_percent_attack_damage_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_PercentAttackDamage"
	if target.has_meta('PercentAttackDamagePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('PercentAttackDamagePassive'):
		target.set_meta('PercentAttackDamagePassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('PercentAttackDamagePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('PercentAttackDamagePassive', target.get_meta('PercentAttackDamagePassive') - old_passive)
		target.set_meta('PercentAttackDamagePassive', target.get_meta('PercentAttackDamagePassive') + value)
		target.global_attack_damage -= old_passive

	target.set_meta(ability_name_clean, value)
	target.global_attack_damage += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

func _handle_percent_damage_passive(target, value, ability):
	var ability_name_clean = ability.replace(" ", "_")
	ability_name_clean += "_PercentDamage"
	if target.has_meta('PercentDamagePassive') and target.has_meta(ability_name_clean) and target.get_meta(ability_name_clean) == value:
		return

	if !target.has_meta('PercentDamagePassive'):
		target.set_meta('PercentDamagePassive', value)

	if target.has_meta(ability_name_clean) and target.has_meta('PercentDamagePassive'):
		var old_passive = target.get_meta(ability_name_clean)
		target.set_meta('PercentDamagePassive', target.get_meta('PercentDamagePassive') - old_passive)
		target.set_meta('PercentDamagePassive', target.get_meta('PercentDamagePassive') + value)
		target.global_damage -= old_passive

	target.set_meta(ability_name_clean, value)
	target.global_damage += target.get_meta(ability_name_clean)
	if target.is_in_group('players'):
		target._update_stats()

# Handles the speed buff action on the target.
# Parameters:
# - target: The target of the action.
# - value: The value of the speed buff.
# - user: The user of the action.
func _handle_speed_buff_action(target, value, user, extra):
	if target.is_in_group('players'):
		if value < 0:
			value += ((target.total_slow_resistance/100) * value)
	target.bonus_speed += value
	if target.is_in_group('players'):
		target._update_stats()
	var timer
	if typeof(user) == TYPE_INT or typeof(user) == TYPE_FLOAT:
		timer = Utility.get_node('TimerCreator')._create_timer(user, true, target)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(extra["Duration"], true, target)
	timer.timeout.connect(_deapply_buff.bind(target, value, "Speed"))
	timer.start()

# Handles the self invincible action on the user.
# Parameters:
# - user: The user of the action.
# - value: The duration of the invincibility.
func _handle_self_invincible_action(user, value, extra):
	invincible_units.append(user)
	_create_light_specifics(user, 0.3, Color.GOLD)
	var timer = Utility.get_node('TimerCreator')._create_timer(value, true, user)
	timer.timeout.connect(_deapply_invincibility.bind(user))
	timer.start()

# Handles the burn action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of damage per tick.
# - user: The user of the action.
func _handle_burn_action(target, value, user, extra):
	if target in invincible_units or _check_if_dead(target) or extra["ability"] == null:
		return
	if target.has_meta("Weaken_amount"):
		value += value * (target.get_meta("Weaken_amount")/100.0)
	var duration = 5
	if target.is_in_group('players'):
		duration = 5 - ((target.total_affliction_resistance/100) * duration)
	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var added_value = 0
	if user.is_in_group('players'):
		for e in user.get_node('InventoryManager').abilities:
			if e._has_tag('BurnPercentDamage') and extra["ability"].find(e.a_name) != -1:
				added_value += value * (e._get_tag('BurnPercentDamage')/100.0)
			if e._has_tag('BurnDuration') and extra["ability"].find(e.a_name) != -1:
				duration += e._get_tag('BurnDuration')

		if burn_effect_values.has("BurnPercentDamage"):
			added_value += value * (burn_effect_values["BurnPercentDamage"]/100.0)
		if burn_effect_values.has("BurnDuration"):
			duration += burn_effect_values["BurnDuration"]
		
		added_value += value * ((user.global_burn_damage/100.0) + (user.global_damage/100.0))
		value += added_value
	var damage_per_tick = value / total_ticks

	var ability_name = extra["ability"].replace(" ", "_")
	if !target.has_node('Burn_timer_' + ability_name):
		var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)
		target.set_meta('Burn_count' + ability_name, 0)
		target.set_meta('Burn_damage' + ability_name, damage_per_tick)
		timer.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'orange', 'Burn', ability_name))
		timer.name = "Burn_timer_" + ability_name

		var burning = burn_effect.instantiate()
		burning.name = "Burn_effect"
		target.add_child(burning)
		timer.start()
	else:
		var echo = 1
		while target.has_node('Burn_timer_' + ability_name + str(echo)):
			echo += 1
		target.set_meta('Burn_count' + ability_name + str(echo), 0)
		target.set_meta('Burn_damage' + ability_name + str(echo), damage_per_tick)
		var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)
		timer.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'orange', 'Burn', ability_name + str(echo)))
		timer.name = "Burn_timer_" + ability_name + str(echo)
		target.add_child(timer)
		timer.start()


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
func _handle_freeze_action(target, value, user, extra):
	if target in invincible_units or _check_if_dead(target) or extra == null or target.total_speed <= 0:
		return
	var duration = 3.0
	var value_to_percent = (value/100.0)
	var new_speed = target.total_speed * value_to_percent
	var frozen_duration = 1.5
	var is_frozen = _chance_calculator(player.total_frozen_chance)
	var chance = 0
	if user.is_in_group('players'):
		for e in user.get_node('InventoryManager').abilities:
			if e._has_tag('FrozenChance') and extra["ability"].find(e.a_name) != -1:
				chance += e._get_tag('FrozenChance')
				is_frozen = _chance_calculator(chance)
			
			if e._has_tag('FrozenDuration') and extra["ability"].find(e.a_name) != -1:
				frozen_duration += e._get_tag('FrozenDuration')

			if e._has_tag('FreezeAmount') and extra["ability"].find(e.a_name) != -1:
				value_to_percent += e._get_tag('FreezeAmount')/100.0
		
		value_to_percent += user.global_freeze_effectiveness
		new_speed = target.total_speed * value_to_percent
		
		if frozen_effect_values.has("FrozenChance"):
			chance += frozen_effect_values["FrozenChance"]
			is_frozen = _chance_calculator(chance)

	if is_frozen:
		var frozen_timer = Utility.get_node('TimerCreator')._create_timer(frozen_duration, true, target)
		frozen_timer.timeout.connect(_deapply_frozen.bind(target))
		frozen_timer.name = "Frozen_timer"
		target.is_frozen = true
		var frozen = frozen_effect.instantiate()
		var size = target.get_node("AnimatedSprite2D").get_sprite_frames().get_frame_texture("Walk South", 0).get_width()
		frozen.scale = Vector2(size/96, size/112)
		frozen.name = "Frozen_effect"
		target.add_child(frozen)
		# Add frozen effects here:
		frozen_targets.append(target)
		if frozen_effect_values.has("FrozenQuickAttack"):
			if _chance_calculator(frozen_effect_values["FrozenQuickAttack"]):
				player.get_node('Control')._attack()
	var timer = Utility.get_node('TimerCreator')._create_timer(duration, true, target)
	timer.timeout.connect(_deapply_freeze.bind(new_speed, target))
	timer.name = "Freeze_timer"
	target.bonus_speed -= new_speed

	var freezing = freeze_effect.instantiate()
	freezing.name = "Freeze_effect"
	target.add_child(freezing)
	timer.start()

func _handle_frozen_action(target, value, user, extra):
	var frozen_duration = value

	if user.is_in_group('players'):
		for e in user.get_node('InventoryManager').abilities:
			
			if e._has_tag('FrozenDuration') and extra["ability"].find(e.a_name) != -1:
				frozen_duration += e._get_tag('FrozenDuration')

	var frozen_timer = Utility.get_node('TimerCreator')._create_timer(frozen_duration, true, target)
	frozen_timer.timeout.connect(_deapply_frozen.bind(target))
	frozen_timer.name = "Frozen_timer"
	target.is_frozen = true
	var frozen = frozen_effect.instantiate()
	var size = target.get_node("AnimatedSprite2D").get_sprite_frames().get_frame_texture("Walk South", 0).get_width()
	frozen.scale = Vector2(size/96.0 + 0.1, size/112.0 + 0.1)
	frozen.name = "Frozen_effect"
	target.add_child(frozen)
	# Add frozen effects here:
	frozen_targets.append(target)
	if frozen_effect_values.has("FrozenQuickAttack"):
		if _chance_calculator(frozen_effect_values["FrozenQuickAttack"]):
			player.get_node('Control')._attack()
	frozen_timer.start()
# Handles the heal action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of health to heal.
func _handle_heal_action(target, value, tag, user):
	var added_value = 0
	if user.is_in_group('players'):
		added_value += value * user.global_heal_effectiveness
		value += added_value
	target.current_health += value
	_trigger_effects(target, value, 'green', tag)
	var effect = heal_effect.instantiate()
	effect.name = "Heal_effect"
	target.add_child(effect)


func _handle_heal_over_time_action(target, value, user, extra):
	if _check_if_dead(target):
		return
	var duration = extra["Duration"]
	var base_heal = value
	var added_heal = 0

	if user.is_in_group('players'):
		added_heal += base_heal * (user.global_heal_effectiveness/100.0)
		base_heal += added_heal
	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var heal_per_tick = base_heal / total_ticks 
	var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)

	if !target.has_node('Heal_timer' + extra["ability"]):
		var timer_name = "Heal_timer" + extra["ability"]
		target.set_meta('Heal_count', 0)
		timer.timeout.connect(_apply_damage_over_time.bind(target, heal_per_tick, user, total_ticks, 'green', 'Heal', timer_name))
		timer.name = timer_name
		target.add_child(timer)
		timer.start()

func _handle_percent_heal_over_time_action(target, value, user, extra):
	if _check_if_dead(target):
		return
	var duration = extra["Duration"]
	var base_heal = target.total_health * (value/100.0)
	var added_heal = 0

	if user.is_in_group('players'):
		added_heal += base_heal * (user.global_heal_effectiveness/100.0)
		base_heal += added_heal
	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var heal_per_tick = base_heal / total_ticks 
	var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)

	if !target.has_node('Heal_timer' + extra["ability"]):
		var timer_name = "Heal_timer" + extra["ability"]
		target.set_meta('Heal_count', 0)
		timer.timeout.connect(_apply_damage_over_time.bind(target, heal_per_tick, user, total_ticks, 'green', 'Heal', timer_name))
		timer.name = timer_name
		target.add_child(timer)
		timer.start()

func _handle_heal_mana_over_time_action(target, value, user, extra):
	if _check_if_dead(target):
		return
	var duration = extra["Duration"]
	var base_heal = value

	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var heal_per_tick = base_heal / total_ticks 
	var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)

	if !target.has_node('ManaHeal_timer' + extra["ability"]):
		var timer_name = "ManaHeal_timer" + extra["ability"]
		target.set_meta('ManaHeal_count', 0)
		timer.timeout.connect(_apply_damage_over_time.bind(target, heal_per_tick, user, total_ticks, 'blue', 'ManaHeal', timer_name))
		timer.name = timer_name
		target.add_child(timer)
		timer.start()

func _handle_percent_heal_mana_over_time_action(target, value, user, extra):
	if _check_if_dead(target):
		return
	var duration = extra["Duration"]
	var base_heal = target.total_mana * (value/100.0)

	var tick_interval = 1
	var total_ticks = ceil(duration / tick_interval)
	var heal_per_tick = base_heal / total_ticks 
	var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)

	if !target.has_node('ManaHeal_timer' + extra["ability"]):
		var timer_name = "ManaHeal_timer" + extra["ability"]
		target.set_meta('ManaHeal_count', 0)
		timer.timeout.connect(_apply_damage_over_time.bind(target, heal_per_tick, user, total_ticks, 'blue', 'ManaHeal', timer_name))
		timer.name = timer_name
		target.add_child(timer)
		timer.start()

# Handles the wind action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of knockback.
# - user: The user of the action.
func _handle_wind_action(target, value, user):
	if target in invincible_units or _check_if_dead(target) or target.is_in_group('boss') or target.is_in_group('special'):
		return
	var direction = (target.global_position - user.global_position).normalized()
	target.set_meta('Knockback_direction', direction)
	target.set_meta('Knockback_origin', target.global_position)
	target.set_meta('Knockback_distance', value)
	knockback_units.append(target)

func _handle_gravity_pull_action(target, value, user):
	if target in invincible_units or _check_if_dead(target) or target.is_in_group('boss') or target.is_in_group('special'):
		return
	var direction = (user.global_position - target.global_position).normalized()
	target.set_meta('Pull_direction', direction)
	target.set_meta('Pull_origin', target.global_position)
	target.set_meta('Pull_distance', value)
	pulled_units.append(target)

func _handle_weaken_action(target, value):
	if target in invincible_units or _check_if_dead(target):
		return
	var duration = 5
	if target.is_in_group('players'):
		duration = 5 - ((target.total_affliction_resistance/100) * duration)
	if !target.has_node('Weaken_timer'):
		var timer = Utility.get_node('TimerCreator')._create_timer(duration, false, target)
		timer.timeout.connect(_deapply_weaken.bind(target, value))
		timer.name = "Weaken_timer"
		target.set_meta('Weaken_amount', value)
		var weaken = weaken_effect.instantiate()
		weaken.name = "Weaken_effect"
		target.add_child(weaken)
		timer.start()
	else:
		target.get_node('Weaken_timer').start(duration)

func _deapply_weaken(target, value):
	target.get_node('Weaken_effect').queue_free()
	target.remove_meta('Weaken_amount')
	if target.is_in_group('players'):
		target._update_stats()


# Handles the bleed action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of damage per tick.
# - user: The user of the action.
func _handle_bleed_action(target, value, user, extra):
	if target in invincible_units or _check_if_dead(target):
		return
	if target.has_meta("Weaken_amount"):
		value += value * (target.get_meta("Weaken_amount")/100.0)
	var duration = 2
	if target.is_in_group('players'):
		duration = 2 - ((target.total_affliction_resistance/100) * duration)
	var tick_interval = 0.5
	var total_ticks = ceil(duration / tick_interval)
	var damage_per_tick = value / total_ticks
	var bleed_stacks = 1
	var added_value = 0
	if user.is_in_group('players'):
		for e in user.get_node('InventoryManager').abilities:
			if e._has_tag('BleedDuration') and extra["ability"].find(e.a_name) != -1:
				duration += e._get_tag('BleedDuration')
			if e._has_tag('BleedAmount') and extra["ability"].find(e.a_name) != -1:
				bleed_stacks += e._get_tag('BleedAmount')
			if e._has_tag('BleedPercentDamage') and extra["ability"].find(e.a_name) != -1:
				added_value += value * (e._get_tag('BleedPercentDamage')/100.0)
		
		added_value += value * ((user.global_bleed_damage/100.0) + (user.global_damage/100.0))
		value += added_value
	
	if !target.has_node('Bleed_timer'):
		var timer = Utility.get_node('TimerCreator')._create_timer(tick_interval, false, target)
		target.set_meta('Bleed_count', 0)
		target.set_meta('Bleed_stacks', bleed_stacks)
		target.set_meta('Bleed_damage', damage_per_tick)
		timer.timeout.connect(_apply_damage_over_time.bind(target, damage_per_tick, user, total_ticks, 'crimson', 'Bleed'))
		timer.name = "Bleed_timer"
		timer.start()
	else:
		if target.get_meta('Bleed_stacks') >= 10:
			return
		target.set_meta('Bleed_count', 0)
		target.set_meta('Bleed_stacks', target.get_meta('Bleed_stacks') + 1)
		if target.get_meta('Bleed_damage') < damage_per_tick:
			target.set_meta('Bleed_damage', damage_per_tick)
		target.get_node('Bleed_timer').start()


# Handles the infected action on the target.
# Parameters:
# - target: The target of the action.
func _handle_infected_action(target):
	if target in invincible_units or _check_if_dead(target):
		return
	var duration = 2
	if target.is_in_group('players'):
		duration = 2 - ((target.total_affliction_resistance/100) * duration)
	var old_weight
	if !target.has_node('Infected_timer'):
		old_weight = target.global_weight
		var timer = Utility.get_node('TimerCreator')._create_timer(duration, false, target)
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

func _handle_mana_overload_action(target, value, user, extra):
	var mana_damage = user.total_mana * (value/100.0)
	_on_do_action(mana_damage, target, user, "Damage", extra)

# Handles the PvE darkness action on the target.
# Parameters:
# - target: The target of the action.
# - value: The amount of damage to deal.
func _handle_pve_darkness_action(target, value, tag):
	if pve_light_units.has(target) or _check_if_dead(target):
		return
	target.current_health -= value
	target.set_meta('Darkness', true)
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
		target.set_meta('Darkness', false)
	if type == 0:
		if pve_light_units.find(target) != -1 and !target.get_meta('Darkness'):
			pve_light_units.clear()
			target.set_meta('Darkness', true)
	return

# ------------------------------------------------------#
# Timeout Handler
# ------------------------------------------------------#

# This function deapplies the frozen effect from a target.
# Parameters:
#   - target: The target from which to deapply the frozen effect.
func _deapply_frozen(target):
	if _check_if_dead(target):
		return
	target.is_frozen = false
	frozen_targets.erase(target)
	if target:
		target.get_node('Frozen_effect').queue_free()
		target.get_node('Frozen_timer').queue_free()

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
	if _check_if_dead(target):
		return
	target.global_weight = old_weight
	target.set_meta('Infected_stacks', 0)
	if target.has_node('Infected_timer'):
		target.get_node('Infected_timer').queue_free()
		target.get_node('Infected_effect').queue_free()

# This function deapplies an attack buff from a target.
# Parameters:
#   - target: The target from which to deapply the attack buff.
#   - value: The value of the attack buff.
#   - tag: The tag associated with the attack buff.
func _deapply_attack_buff(target, value, tag):
	if _check_if_dead(target):
		return

	var index = target.current_attack_modifier_tags.find(tag)
	
	target.current_attack_modifier_tags.erase(tag)
	target.current_attack_modifier_values.erase(value)
	target.current_attack_modifier_abilities.erase(target.current_attack_modifier_abilities[index])

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
	if _check_if_dead(target):
		return
	target.bonus_speed += original_speed
	if target.has_node('Freeze_timer'):
		target.get_node('Freeze_timer').queue_free()
	if target.has_node('Freeze_effect'):
		target.get_node('Freeze_effect').queue_free()

# This function deapplies the stealth effect from a user.
# Parameters:
#   - user: The user from which to deapply the stealth effect.
func _deapply_stealth(user):
	if _check_if_dead(user):
		return
	user.in_stealth = false

# This function deapplies a buff from a target.
# Parameters:
#   - target: The target from which to deapply the buff.
#   - value: The value of the buff.
#   - tag: The tag associated with the buff.
func _deapply_buff(target, value, tag):
	if _check_if_dead(target):
		return
	if tag == "Armor":
		target.bonus_armor -= value
	if tag == "Speed":
		target.bonus_speed -= value
	if tag == "AttackSpeed":
		target.bonus_attack_speed -= value
	if tag == "BurnReflect":
		target.set_meta('BurnReflectBuff', target.get_meta('BurnReflectBuff') - value)
		if target.get_meta('BurnReflectBuff') <= 0:
			target.remove_meta('BurnReflectBuff')
	if tag == "Shock":
		target.get_node('Shock_timer').queue_free()
		target.set_meta('Shock_count', 0)
	if tag == "Damage":
		target.bonus_attack_damage -= value
	if tag == "CriticalChance":
		target.bonus_critical_chance -= value
	if tag == "ManaRegen":
		target.bonus_mana_regen -= value
	if tag == "Root":
		target.is_rooted = false
		target.get_node('Root_effect').queue_free()
	if tag == "FlatArmor":
		target.bonus_armor -= value
	if tag == "Affliction":
		target.bonus_affliction_resistance -= value
	if tag == "Evade":
		target.bonus_evade -= value
	if tag == "RageRegen":
		target.rage_regen -= value
	if tag == "Stun":
		target.is_stunned = false
		target.get_node("Stun_effect").queue_free()
	if tag == "Taunt":
		target.is_taunted = false
		target.get_node("Taunt_effect").queue_free()
	if tag == "Thorns":
		target.bonus_thorns -= value
	
	if target.is_in_group('players'):
		target._update_stats()

func _deapply_global_buff(target, value, tag):
	if _check_if_dead(target):
		return
	if tag == "Armor":
		target.global_armor -= value
	if tag == "Speed":
		target.global_movement_speed -= value
	if tag == "AttackDamage":
		target.global_attack_damage -= value
	if tag == "ManaRegen":
		target.global_mana_regen -= value
	if tag == "Evade":
		target.global_evade -= value
	if tag == "Damage":
		target.global_damage -= value
	if tag == "Health":
		target.global_health -= value
	if tag == "Size":
		target.global_size -= value
	if tag == "PoisonDamage":
		target.global_poison_damage -= value
	
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
func _apply_damage_over_time(target, damage_per_tick, user, total_ticks, color, type, timer_name = null):
	if "Heal" not in type:
		if target in invincible_units or _check_if_dead(target) or get_tree().get_nodes_in_group("players")[0].paused:
			return
	var damage
	print(type)
	if type == "Bleed":
		damage = _calculate_reduced_damage(target.get_meta("Bleed_damage") * (1 + target.get_meta('Bleed_stacks')/2), target.total_armor)
	elif type == "Frenzy" or type == "Heal":
		damage = damage_per_tick
	elif type == "Poison":
		damage = float(damage_per_tick * (target.get_meta("Poison_stacks")))
		print(damage)
		if !poisoned_targets.has(target):
			poisoned_targets.append(target)
	else:    
		damage = _calculate_reduced_damage(damage_per_tick, target.total_armor)
		if burn_effect_values.has("BurnHeal"):
			if user == player:
				_on_do_action(damage * (burn_effect_values['BurnHeal']/100.0), user, target, "Heal")

		for e in player.get_node('InventoryManager').abilities:
			if e._has_tag('BurnExplosion'):
				if !timers.has('BurnExplosion'):
					timers['BurnExplosion'] = e._get_enchant_extras('BurnExplosion')['Cooldown']

				if timers['BurnExplosion'] <= 0:
					timers['BurnExplosion'] = e._get_enchant_extras('BurnExplosion')['Cooldown']
					var new_explosion = explosion_effect.instantiate()
					new_explosion.global_position = target.global_position
					new_explosion.get_child(0).color = Color.ORANGE
					new_explosion.get_child(0).scale = Vector2(e._get_enchant_extras('BurnExplosion')['Radius']/100, e._get_enchant_extras('BurnExplosion')['Radius']/100)
					get_tree().get_root().add_child(new_explosion)
					new_explosion.get_child(0).emitting = true
					for enemy in get_tree().get_nodes_in_group('enemies'):
						if enemy.global_position.distance_to(new_explosion.global_position) < e._get_enchant_extras('BurnExplosion')['Radius']:
							_on_do_action(damage * 3, enemy, user, "Damage")
						break
		
	if extra_effect_values.has("ManaShield"):
		if target.is_in_group("players"):
			var potential_damage = damage * (1 - (extra_effect_values["ManaShield"]/100.0))
			var mana_damage = damage - potential_damage
			if target.current_mana >= mana_damage:
				target.current_mana -= mana_damage
				damage = potential_damage
			else:
				damage -= target.current_mana
				target.current_mana = 0

	if type == "Heal":
		target.current_health += damage
	elif type == "ManaHeal":
		target.current_mana += damage
	else:
		target.current_health -= _barrier_protection(target, damage)

	_trigger_combat_text(target, damage, color)
	
	var current_tick = 0
	if target.has_meta(type + "_count"):
		current_tick = target.get_meta(type + "_count")
		target.set_meta(type + "_count", current_tick + 1)

	if target.has_meta(type + "_count" + str(timer_name)):
		current_tick = target.get_meta(type + "_count" + str(timer_name))
		target.set_meta(type + "_count" + str(timer_name), current_tick + 1)

	if current_tick >= total_ticks:
		if _check_if_dead(target):
			return
		if type == "Burn" and target.has_node("Burn_effect") and !_check_if_dead(target):
			target.get_node("Burn_effect").queue_free()
		if type == "Poison" and !_check_if_dead(target):
			if target.has_node("Poison_effect"):
				target.get_node("Poison_effect").queue_free()
			target.set_meta(str(timer_name), 0)
			poisoned_targets.erase(target)
			if target.has_node("Poison_timer"):
				target.get_node("Poison_timer").queue_free()
			return
		if target.has_node(type + "_timer") and !_check_if_dead(target):
			target.get_node(type + "_timer").queue_free()
		if timer_name != null and !_check_if_dead(target) and target.has_node(type + "_timer_" + timer_name):
			target.get_node(type + "_timer_" + timer_name).queue_free()
		if timer_name != null and !_check_if_dead(target) and target.has_node(timer_name):
			target.get_node(timer_name).queue_free()
	_update_boss_health_bar(target, user)
	if type != "Heal" or "ManaHeal":
		_trigger_hit_effect(target, type)
	if _check_if_dead(target):
		return

#------------------------------------------------------#
# Extras signals and methods
#------------------------------------------------------#
func _on_character_selected(unit):
	unit.get_node('Control').on_action.connect(_on_do_action)
	unit.get_node('Control').basic_attacking.connect(_on_basic_attack)
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
		
	
func _check_if_dead(unit, value = 0, color = 'red'):
	if !is_instance_valid(unit):
		return true
	if unit.is_queued_for_deletion():
		return true
	if unit.current_health <= 0:
		_trigger_combat_text(unit.global_position, value, color)
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
		if !target.is_in_group('boss') or !target.is_in_group('special'):
			_on_do_action(15, target, player, "Wind")
		if !target.has_node('HitEffect'):
			var instance = hit_effect.instantiate()
			target.add_child(instance)
			var random = randi_range(0, 2)
			instance.get_node('AnimatedSprite2D').play(str(random))


	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.5
	timer.timeout.connect(_deapply_trigger_effect.bind(target, original_material))
	target.add_child(timer)
	timer.start()

func _create_light_specifics(targett, dura, color):
	var instance = load('res://Abilities/Utility/self_effect.tscn').instantiate()
	instance.get_child(0).color = color
	targett.add_child(instance)
	var timer
	timer = Utility.get_node('TimerCreator')._create_timer(dura, true, instance)
	timer.timeout.connect(_remove_light.bind(instance, targett))
	timer.start()

func _remove_light(instance, targett):
	targett.remove_child(instance)
	instance.queue_free()

func _deapply_trigger_effect(target, original_material):
	original_material.set_shader_parameter('hit_effect_intensity', 0.0)
	target.get_node('AnimatedSprite2D').material = original_material
	target.set_meta("hit_effect", false)
	
func _create_combat_text_and_update_recent(value, current_time, target, color):
	recent_combat_text_values[target][color] = value
	recent_combat_text_timestamps[target][color] = current_time
	var instanced = combat_text.instantiate()
	recent_combat_text_instances[target][color] = instanced
	instanced._create_text(recent_combat_text_values[target][color], target, color, player)

func _trigger_combat_text(target, value, color):
	if _check_if_dead(target, value, color) and typeof(target) == TYPE_OBJECT:
		return
	value = ceil(value)
	var current_time = Time.get_ticks_msec() / 1000.0
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

func save():
	var save_dict = {
		"filename" : get_path(),
		"parent" : get_parent().get_path(),
		"global_increases": global_increases,
		"global_defense_passives": global_defense_passives,
		"recent_combat_text_values": recent_combat_text_values,
		"recent_combat_text_timestamps": recent_combat_text_timestamps,
		"recent_combat_text_instances": recent_combat_text_instances,
		"invincible_units": invincible_units,
		"knockback_units": knockback_units,
		"pve_light_units": pve_light_units,
		"special_objects": special_objects,
		"current_marked_pair": current_marked_pair
	}
	return save_dict
