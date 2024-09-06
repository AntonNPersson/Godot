# FILEPATH: /C:/Users/Anton/Documents/Godot/Units/Stats/playerVariables.gd

extends Area2D
class_name player_variables

var obstacles_info

# Signal emitted when the unit is dead
signal is_dead(unit)
@onready var health_bar = get_node("UI/ProgressBar")
@onready var barrier_bar = get_node("UI/ProgressBar2")
@onready var level_up_effect = get_node("Extra/LevelUpEffect")

# Reference to the target marker node
@onready var target_marker = get_node("UI/TargetMarker")

# Exported variables
@export_group("Skills and Abilities")
@export var basic_attack_scene : PackedScene
@export var movement_skill_scene : PackedScene
@export var type : Array[String]
var movement_skill
var player_is_ready = false
var item_manager = null

# Player variables
var in_combat = false
var in_stealth = false
var melee = false
var gold = 0
var global_weight : float = int(0)
var global_movement_speed : float = int(0)
var global_evade : float = int(0)
var global_armor : float = int(0)
var global_strength : float = int(0)
var global_dexterity : float = int(0)
var global_intelligence : float = int(0)
var global_vitality : float = int(0)
var global_health_regen : float = int(0)
var global_mana_regen : float = int(0)
var global_stamina_regen : float = int(0)
var global_barrier_regen : float = int(0)
var global_health : float = int(0)
var global_barrier : float = int(0)
var global_mana : float = int(0)
var global_stamina : float = int(0)
var global_bleed_damage : float = int(0)
var global_burn_damage : float = int(0)
var global_freeze_effectiveness : float = int(0)
var global_heal_effectiveness : float = int(0)
var global_damage : float = int(0)

var global_dict = {
	"Bleed" : global_bleed_damage,
	"Burn" : global_burn_damage,
	"Freeze" : global_freeze_effectiveness,
	"Heal" : global_heal_effectiveness,
	"Damage" : global_damage
}

var total_charge_drop_chance : float = 15
var total_armor : float
var total_evade : float
var total_speed : float
var total_barrier : float
var total_health : float
var total_mana : float
var total_stamina : float
var total_range : float
var total_attack_speed : float
var total_attack_damage : float
var total_windup_time : float
var total_strength : float
var total_dexterity : float
var total_intelligence : float
var total_vitality : float
var total_health_regen : float
var total_mana_regen : float
var total_stamina_regen : float
var total_barrier_regen : float
var total_ability_experience : float
var total_player_experience : float = 100
var total_cooldown_reduction : float
var total_quick_attack_chance : float
var total_double_cast_chance : float
var total_critical_chance : float
var total_critical_damage : float
var total_attack_targets : float

# Exported variables for base stats
@export_group("Base Stats")
@export var c_name = 'Player'
@export var tooltip = ''
@export var base_armor = 0
@export var base_evade = 0
@export var base_speed = 500
@export var base_barrier = 0
@export var base_health = 100
@export var base_mana = 100
@export var base_stamina = 100
@export var base_range = 700
@export var base_attack_speed = 0.6
@export var base_attack_damage = 30
@export var base_windup_time = 1.0
@export var base_strength = 10
@export var base_dexterity = 10
@export var base_intelligence = 10
@export var base_vitality = 10
@export var base_health_regen = 0.5
@export var base_mana_regen = 0.5
@export var base_stamina_regen = 2
@export var base_barrier_regen = 1
@export var base_cooldown_reduction = 0
@export var base_quick_attack_chance = 0
@export var base_double_cast_chance = 0
@export var base_critical_chance = 0
@export var base_critical_damage = 125
@export var base_attack_targets = 1

# Bonus variables
var bonus_armor = 0.0
var bonus_evade = 0.0
var bonus_speed = 0.0
var bonus_barrier = 0.0
var bonus_health = 0.0
var bonus_mana = 0.0
var bonus_stamina = 0.0
var bonus_range = 0.0
var bonus_attack_speed = 0.0
var bonus_attack_damage = 0.0
var bonus_strength = 0.0
var bonus_dexterity = 0.0
var bonus_intelligence = 0.0
var bonus_vitality = 0.0
var bonus_health_regen = 0.0
var bonus_mana_regen = 0.0
var bonus_stamina_regen = 0.0
var bonus_barrier_regen = 0.0
var bonus_cooldown_reduction = 0.0
var bonus_quick_attack_chance = 0.0
var bonus_double_cast_chance = 0.0
var bonus_critical_chance = 0.0
var bonus_critical_damage = 0.0
var bonus_attack_targets = 0.0

# Current health, mana, stamina and other values
var current_barrier = 0
var current_health = 100
var current_mana = 100
var current_stamina = 100
var current_player_experience = 0

# Current attack modifier tags and values
var current_attack_modifier_tags = []
var current_attack_modifier_values = []

var regen_timer = 0

# Saved variables
var completed_waves = []
var power = 1
var ascension_level = 0
var ascension_currency = 0

var paused = false
var lose_camera_focus = false
var PLAYER_LEVEL_UP_SCALING = 1.5
var HEALTH_LEVEL_UP_AMOUNT = 0
var MANA_LEVEL_UP_AMOUNT = 0
var STAMINA_LEVEL_UP_AMOUNT = 0
var STRENGTH_LEVEL_UP_AMOUNT = 0
var DEXTERITY_LEVEL_UP_AMOUNT = 0
var INTELLIGENCE_LEVEL_UP_AMOUNT = 0

# Saved inventory manager variables.
var im_inventory = null
var im_potions = null
var im_abilities = null
var im_potion_charges = null
var im_current_potion_charges = null
var im_cooldown_timers = null

# Calculate the percentage based on current and total values
func _calculate_percentage(current, total):
	return (current / total) * 100

func _calculate_power():
	var power = 0
	power += bonus_strength * 0.4
	power += bonus_dexterity * 0.4
	power += bonus_intelligence * 0.4
	power += bonus_vitality * 0.4
	power += total_health * (bonus_armor/1000)
	power += total_health * (bonus_evade/1000)
	power += bonus_health
	power += bonus_barrier
	power += bonus_mana
	power += bonus_stamina
	power += bonus_attack_damage * (bonus_quick_attack_chance/100)
	power += bonus_attack_damage
	power += bonus_attack_speed/100 * bonus_attack_damage
	power += bonus_attack_damage * (bonus_range/1000)
	power += bonus_range * bonus_attack_damage
	power += total_health * (bonus_health_regen/200)
	power += total_mana * (bonus_mana_regen/200)
	power += total_stamina * (bonus_stamina_regen/200)
	for i in (get_node('InventoryManager').abilities):
		power += get_node('InventoryManager').abilities[i]._calculate_power()
	power +=  bonus_speed * 2
	return power
	
# Update the regeneration of health, mana, and stamina
func _update_regen(delta):
	if current_health > total_health:
		current_health = total_health
	if current_mana > total_mana:
		current_mana = total_mana
	if current_stamina > total_stamina:
		current_stamina = total_stamina
	if current_barrier > total_barrier:
		current_barrier = total_barrier

	regen_timer += delta
	if regen_timer < 1:
		return
	
	if current_health < total_health:
		current_health += total_health_regen
	if current_mana < total_mana:
		current_mana += total_mana_regen
	if current_stamina < total_stamina:
		current_stamina += total_stamina_regen
	if current_barrier < total_barrier:
		if in_combat:
			current_barrier += total_barrier_regen/3
		else:
			current_barrier += total_barrier_regen
	regen_timer = 0
	
# Update the total stats
func _update_stats():
	_update_totals()

# Update the total values of stats
func _update_totals():
	total_strength = (base_strength + bonus_strength) * (1 + global_strength/100)
	total_dexterity = (base_dexterity + bonus_dexterity) * (1 + global_dexterity/100)
	total_intelligence = (base_intelligence + bonus_intelligence) * (1 + global_intelligence/100)
	total_vitality = (base_vitality + bonus_vitality) * (1 + global_vitality/100)
	total_speed = (base_speed + bonus_speed + (total_dexterity/100)) * (1 + global_movement_speed/100)
	total_health = (base_health + bonus_health + (total_vitality * 2)) * (1 + global_health/100)
	total_mana = (base_mana + bonus_mana + (total_intelligence * 2)) * (1 + global_mana/100)
	total_stamina = (base_stamina + bonus_stamina + (total_strength / 10)) * (1 + global_stamina/100)
	total_armor = (base_armor + bonus_armor) * (1 + global_armor/100)
	total_evade = (base_evade + bonus_evade) * (1 + global_evade/100)
	total_range = base_range + bonus_range 
	total_attack_speed = base_attack_speed * (1 + bonus_attack_speed/100)
	total_attack_damage = base_attack_damage + bonus_attack_damage
	total_windup_time = base_windup_time/(total_attack_speed)
	total_health_regen = (base_health_regen + bonus_health_regen) * (1 + global_health_regen/100)
	total_mana_regen = (base_mana_regen + bonus_mana_regen) * (1 + global_mana_regen/100)
	total_stamina_regen = (base_stamina_regen + bonus_stamina_regen) * (1 + global_stamina_regen/100)
	total_cooldown_reduction = base_cooldown_reduction + bonus_cooldown_reduction
	total_quick_attack_chance = base_quick_attack_chance + bonus_quick_attack_chance
	total_double_cast_chance = base_double_cast_chance + bonus_double_cast_chance
	total_barrier = (base_barrier + bonus_barrier) * (1 + global_barrier/100)
	total_barrier_regen = (base_barrier_regen + bonus_barrier_regen) * (1 + global_barrier_regen/100)
	total_critical_chance = base_critical_chance + bonus_critical_chance
	total_critical_damage = base_critical_damage + bonus_critical_damage
	total_attack_targets = base_attack_targets + bonus_attack_targets

	print(global_barrier/100)
	
# Called when the node is ready
func _ready():
	health_bar._update_health(_calculate_percentage(current_health, total_health))
	_update_stats()
	current_health = total_health
	current_mana = total_mana
	current_stamina = total_stamina
	current_barrier = total_barrier

# Process function called every frame
func _process(delta):
	if paused:
		return
	# Why the fuck is this nessecary suddenly?
	if movement_skill == null:
		print_debug('Movement_skill added at runtime for some reason?')
		movement_skill = movement_skill_scene.instantiate()
		movement_skill.unit = self
		add_child(movement_skill)
	_check_player_level_up()
	health_bar._update_health(_calculate_percentage(current_health, total_health))
	barrier_bar._update_barrier(_calculate_percentage(current_barrier, total_barrier))
	_update_regen(delta)
	if total_speed < 0:
		total_speed = 0
	
	if in_stealth:
		remove_from_group("players")
	else:
		add_to_group("players")

	if total_attack_speed < 0.1:
		total_attack_speed = 0.1

	if current_mana < 0:
		current_mana = 0
	if current_health < 0:
		is_dead.emit(self)
		Utility.get_node("Transition")._start_death(2, ascension_currency, ascension_level)
		paused = true
	if current_stamina < 0:
		current_stamina = 0
	if current_barrier < 0:
		current_barrier = 0

func _add_completed_wave(wave):
	if wave not in completed_waves:
		completed_waves.append(wave)

func _get_completed_waves():
	return completed_waves

func _reset_completed_waves():
	completed_waves.clear()

func _is_all_waves_completed():
	if completed_waves.size() >= get_tree().get_root().get_node('Main').get_child(0).get_node("WaveManager")._get_total_waves():
		return true
	else:
		return false

func _apply_cooldown_reduction(value):
	value = value * (1 - total_cooldown_reduction/100)
	return value

func _apply_bleed_damage(value):
	value = value * (1 + global_bleed_damage/100)
	return value

func _apply_quick_attack_chance():
	var amount_of_attacks = 1
	var extra_chance = total_quick_attack_chance

	var rnd = randf_range(0, 100)
	if rnd < extra_chance:
		amount_of_attacks += 1
		extra_chance -= 100
		while extra_chance > 0:
			rnd = randf_range(0, 100)
			if rnd < extra_chance:
				amount_of_attacks += 1
				extra_chance -= 100
			else:
				extra_chance = 0
	
	return amount_of_attacks

func _apply_double_cast_chance():
	var rnd = randf_range(0, 100)
	if rnd < total_double_cast_chance:
		return true
	else:
		return false

func _apply_critical_chance():
	var rnd = randf_range(0, 100)
	if rnd < total_critical_chance:
		return true
	else:
		return false

func _apply_critical_damage(value):
	if _apply_critical_chance():
		value = value * (1 + total_critical_damage/100)
	return value

func _check_player_level_up():
	if current_player_experience >= total_player_experience:
		_on_player_level_up()

func _on_player_level_up():
	total_player_experience = 100 + (total_player_experience * PLAYER_LEVEL_UP_SCALING)
	current_player_experience = 0
	level_up_effect.get_child(0).emitting = true
	_on_add_stats({
		"health" : HEALTH_LEVEL_UP_AMOUNT,
		"mana" : MANA_LEVEL_UP_AMOUNT,
		"stamina" : STAMINA_LEVEL_UP_AMOUNT,
		"strength" : STRENGTH_LEVEL_UP_AMOUNT,
		"dexterity" : DEXTERITY_LEVEL_UP_AMOUNT,
		"intelligence" : INTELLIGENCE_LEVEL_UP_AMOUNT
	})

# Called when stats are added
func _on_add_stats(value):
	if "health" in value:
		bonus_health += value.health
		current_health += value.health
	if "mana" in value:
		bonus_mana += value.mana
		current_mana += value.mana
	if "stamina" in value:
		bonus_stamina += value.stamina
		current_stamina += value.stamina
	if "speed" in value:
		bonus_speed += value.speed
	if "range" in value:
		if value.range > 50:
			melee = false
		else:
			melee = true
		bonus_range += value.range
	if "attack_speed" in value:
		bonus_attack_speed += value.attack_speed
	if "attack_damage" in value:
		bonus_attack_damage += value.attack_damage
	if "strength" in value:
		bonus_strength += value.strength
	if "dexterity" in value:
		bonus_dexterity += value.dexterity
	if "intelligence" in value:
		bonus_intelligence += value.intelligence
	if "vitality" in value:
		bonus_vitality += value.vitality
	if "armor" in value:
		bonus_armor += value.armor
	if "health_regen" in value:
		bonus_health_regen += value.health_regen
	if "mana_regen" in value:
		bonus_mana_regen += value.mana_regen
	if "stamina_regen" in value:
		bonus_stamina_regen += value.stamina_regen
	if "evade" in value:
		bonus_evade += value.evade
	if "cooldown_reduction" in value:
		bonus_cooldown_reduction += value.cooldown_reduction
	if "quick_attack_chance" in value:
		bonus_quick_attack_chance += value.quick_attack_chance
	if "double_cast_chance" in value:
		bonus_double_cast_chance += value.double_cast_chance
	if "barrier" in value:
		bonus_barrier += value.barrier
		current_barrier += value.barrier
	if "critical_chance" in value:
		bonus_critical_chance += value.critical_chance
	if "critical_damage" in value:
		bonus_critical_damage += value.critical_damage
	if "increased_movement_speed" in value:
		global_movement_speed += value.increased_movement_speed
	if "increased_evade" in value:
		global_evade += value.increased_evade
	if "increased_armor" in value:
		global_armor += value.increased_armor
	if "increased_strength" in value:
		global_strength += value.increased_strength
	if "increased_dexterity" in value:
		global_dexterity += value.increased_dexterity
	if "increased_intelligence" in value:
		global_intelligence += value.increased_intelligence
	if "increased_vitality" in value:
		global_vitality += value.increased_vitality
	if "increased_health_regen" in value:
		global_health_regen += value.increased_health_regen
	if "increased_mana_regen" in value:
		global_mana_regen += value.increased_mana_regen
	if "increased_stamina_regen" in value:
		global_stamina_regen += value.increased_stamina_regen
	if "increased_barrier_regen" in value:
		global_barrier_regen += value.increased_barrier_regen
	if "increased_health" in value:
		global_health += value.increased_health
	if "increased_barrier" in value:
		print("barrer increas: " + str(value.increased_barrier))
		global_barrier += value.increased_barrier
	if "increased_mana" in value:
		global_mana += value.increased_mana
	if "increased_stamina" in value:
		global_stamina += value.increased_stamina
	if "increased_bleed_damage" in value:
		global_bleed_damage += value.increased_bleed_damage
	if "increased_burn_damage" in value:
		global_burn_damage += value.increased_burn_damage
	if "increased_freeze_effectiveness" in value:
		global_freeze_effectiveness += value.increased_freeze_effectiveness
	if "increased_heal_effectiveness" in value:
		global_heal_effectiveness += value.increased_heal_effectiveness
	if "increased_damage" in value:
		global_damage += value.increased_damage
	if "attack_targets" in value:
		bonus_attack_targets += value.attack_targets
	if "increased_global_weight" in value:
		global_weight += value.increased_global_weight
	_update_stats()

# Called when stats are removed
func _on_remove_stats(value):
	if "health" in value:
		bonus_health -= value.health
	if "mana" in value:
		bonus_mana -= value.mana
	if "stamina" in value:
		bonus_stamina -= value.stamina
	if "speed" in value:
		bonus_speed -= value.speed
	if "range" in value:
		bonus_range -= value.range
	if "attack_speed" in value:
		bonus_attack_speed -= value.attack_speed
	if "attack_damage" in value:
		bonus_attack_damage -= value.attack_damage
	if "strength" in value:
		bonus_strength -= value.strength
	if "dexterity" in value:
		bonus_dexterity -= value.dexterity
	if "intelligence" in value:
		bonus_intelligence -= value.intelligence
	if "vitality" in value:
		bonus_vitality -= value.vitality
	if "armor" in value:
		bonus_armor -= value.armor
	if "health_regen" in value:
		bonus_health_regen -= value.health_regen
	if "mana_regen" in value:
		bonus_mana_regen -= value.mana_regen
	if "stamina_regen" in value:
		bonus_stamina_regen -= value.stamina_regen
	if "evade" in value:
		bonus_evade -= value.evade
	if "cooldown_reduction" in value:
		bonus_cooldown_reduction -= value.cooldown_reduction
	if "quick_attack_chance" in value:
		bonus_quick_attack_chance -= value.quick_attack_chance
	if "double_cast_chance" in value:
		bonus_double_cast_chance -= value.double_cast_chance
	if "barrier" in value:
		bonus_barrier -= value.barrier
		current_barrier -= value.barrier
	if "critical_chance" in value:
		bonus_critical_chance -= value.critical_chance
	if "critical_damage" in value:
		bonus_critical_damage -= value.critical_damage
	if "increased_movement_speed" in value:
		global_movement_speed -= value.increased_movement_speed
	if "increased_evade" in value:
		global_evade -= value.increased_evade
	if "increased_armor" in value:
		global_armor -= value.increased_armor
	if "increased_strength" in value:
		global_strength -= value.increased_strength
	if "increased_dexterity" in value:
		global_dexterity -= value.increased_dexterity
	if "increased_intelligence" in value:
		global_intelligence -= value.increased_intelligence
	if "increased_vitality" in value:
		global_vitality -= value.increased_vitality
	if "increased_health_regen" in value:
		global_health_regen -= value.increased_health_regen
	if "increased_mana_regen" in value:
		global_mana_regen -= value.increased_mana_regen
	if "increased_stamina_regen" in value:
		global_stamina_regen -= value.increased_stamina_regen
	if "increased_barrier_regen" in value:
		global_barrier_regen -= value.increased_barrier_regen
	if "increased_health" in value:
		global_health -= value.increased_health
	if "increased_barrier" in value:
		global_barrier -= value.increased_barrier
	if "increased_mana" in value:
		global_mana -= value.increased_mana
	if "increased_stamina" in value:
		global_stamina -= value.increased_stamina
	if "increased_bleed_damage" in value:
		global_bleed_damage -= value.increased_bleed_damage
	if "increased_burn_damage" in value:
		global_burn_damage -= value.increased_burn_damage
	if "increased_freeze_effectiveness" in value:
		global_freeze_effectiveness -= value.increased_freeze_effectiveness
	if "increased_heal_effectiveness" in value:
		global_heal_effectiveness -= value.increased_heal_effectiveness
	if "increased_damage" in value:
		global_damage -= value.increased_damage
	if "attack_targets" in value:
		bonus_attack_targets -= value.attack_targets
	if "increased_global_weight" in value:
		global_weight -= value.increased_global_weight
	_update_stats()

func save():
		var ability_data = []
		var ability_manager = get_node("InventoryManager").abilities
		for i in range(ability_manager.size()):
			ability_data.append(ability_manager[i]._get_ability_data())
		im_abilities = ability_data

		var inventory_data = []
		var inventory_manager = get_node("InventoryManager").inventory
		for i in range(inventory_manager.size()):
			inventory_data.append(inventory_manager[i]._get_item_data())
		im_inventory = inventory_data

		get_node("InventoryManager")._remove_item_stats_from_inventory()

		var save_dict = {
			"filename" : get_path(),
			"melee" : melee,
			"gold" : gold,
			"global_weight" : global_weight,
			"global_movement_speed" : global_movement_speed,
			"global_evade" : global_evade,
			"global_armor" : global_armor,
			"global_strength" : global_strength,
			"global_dexterity" : global_dexterity,
			"global_intelligence" : global_intelligence,
			"global_vitality" : global_vitality,
			"global_health_regen" : global_health_regen,
			"global_mana_regen" : global_mana_regen,
			"global_stamina_regen" : global_stamina_regen,
			"global_barrier_regen" : global_barrier_regen,
			"global_health" : global_health,
			"global_barrier" : global_barrier,
			"global_mana" : global_mana,
			"global_stamina" : global_stamina,
			"global_bleed_damage" : global_bleed_damage,
			"global_burn_damage" : global_burn_damage,
			"global_freeze_effectiveness" : global_freeze_effectiveness,
			"global_heal_effectiveness" : global_heal_effectiveness,
			"global_damage" : global_damage,
			"total_charge_drop_chance" : total_charge_drop_chance,
			"total_armor" : total_armor,
			"total_evade" : total_evade,
			"total_speed" : total_speed,
			"total_barrier" : total_barrier,
			"total_health" : total_health,
			"total_mana" : total_mana,
			"total_stamina" : total_stamina,
			"total_range" : total_range,
			"total_attack_speed" : total_attack_speed,
			"total_attack_damage" : total_attack_damage,
			"total_windup_time" : total_windup_time,
			"total_strength" : total_strength,
			"total_dexterity" : total_dexterity,
			"total_intelligence" : total_intelligence,
			"total_vitality" : total_vitality,
			"total_health_regen" : total_health_regen,
			"total_mana_regen" : total_mana_regen,
			"total_stamina_regen" : total_stamina_regen,
			"total_barrier_regen" : total_barrier_regen,
			"total_ability_experience" : total_ability_experience,
			"total_player_experience" : total_player_experience,
			"total_cooldown_reduction" : total_cooldown_reduction,
			"total_quick_attack_chance" : total_quick_attack_chance,
			"total_double_cast_chance" : total_double_cast_chance,
			"total_critical_chance" : total_critical_chance,
			"total_critical_damage" : total_critical_damage,
			"total_attack_targets" : total_attack_targets,
			"base_armor" : base_armor,
			"base_evade" : base_evade,
			"base_speed" : base_speed,
			"base_barrier" : base_barrier,
			"base_health" : base_health,
			"base_mana" : base_mana,
			"base_stamina" : base_stamina,
			"base_range" : base_range,
			"base_attack_speed" : base_attack_speed,
			"base_attack_damage" : base_attack_damage,
			"base_windup_time" : base_windup_time,
			"base_strength" : base_strength,
			"base_dexterity" : base_dexterity,
			"base_intelligence" : base_intelligence,
			"base_vitality" : base_vitality,
			"base_health_regen" : base_health_regen,
			"base_mana_regen" : base_mana_regen,
			"base_stamina_regen" : base_stamina_regen,
			"base_barrier_regen" : base_barrier_regen,
			"base_cooldown_reduction" : base_cooldown_reduction,
			"base_quick_attack_chance" : base_quick_attack_chance,
			"base_double_cast_chance" : base_double_cast_chance,
			"base_critical_chance" : base_critical_chance,
			"base_critical_damage" : base_critical_damage,
			"base_attack_targets" : base_attack_targets,
			"bonus_armor" : bonus_armor,
			"bonus_evade" : bonus_evade,
			"bonus_speed" : bonus_speed,
			"bonus_barrier" : bonus_barrier,
			"bonus_health" : bonus_health,
			"bonus_mana" : bonus_mana,
			"bonus_stamina" : bonus_stamina,
			"bonus_range" : bonus_range,
			"bonus_attack_speed" : bonus_attack_speed,
			"bonus_attack_damage" : bonus_attack_damage,
			"bonus_strength" : bonus_strength,
			"bonus_dexterity" : bonus_dexterity,
			"bonus_intelligence" : bonus_intelligence,
			"bonus_vitality" : bonus_vitality,
			"bonus_health_regen" : bonus_health_regen,
			"bonus_mana_regen" : bonus_mana_regen,
			"bonus_stamina_regen" : bonus_stamina_regen,
			"bonus_barrier_regen" : bonus_barrier_regen,
			"bonus_cooldown_reduction" : bonus_cooldown_reduction,
			"bonus_quick_attack_chance" : bonus_quick_attack_chance,
			"bonus_double_cast_chance" : bonus_double_cast_chance,
			"bonus_critical_chance" : bonus_critical_chance,
			"bonus_critical_damage" : bonus_critical_damage,
			"bonus_attack_targets" : bonus_attack_targets,
			"current_barrier" : current_barrier,
			"current_health" : current_health,
			"current_mana" : current_mana,
			"current_stamina" : current_stamina,
			"current_player_experience" : current_player_experience,
			"current_attack_modifier_tags" : current_attack_modifier_tags,
			"current_attack_modifier_values" : current_attack_modifier_values,
			"regen_timer" : regen_timer,
			"completed_waves" : completed_waves,
			"power" : power,
			"ascension_level" : ascension_level,
			"ascension_currency" : ascension_currency,
			"paused" : paused,
			"lose_camera_focus" : lose_camera_focus,
			"im_inventory" : im_inventory,
			"im_potions" : im_potions,
			"im_abilities" : im_abilities,
			"im_potion_charges" : get_node('InventoryManager').potion_charges,
			"im_current_potion_charges" : get_node('InventoryManager').current_potion_charges,
			"im_cooldown_timers" : get_node('InventoryManager').cooldown_timers
		}

		get_node("InventoryManager")._add_item_stats_from_inventory()
		return save_dict