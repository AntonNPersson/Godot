# FILEPATH: /C:/Users/Anton/Documents/Godot/Units/Stats/playerVariables.gd

extends Area2D
class_name player_variables

var obstacles_info

# Signal emitted when the unit is dead
signal is_dead(unit)
@onready var health_bar = get_node("UI/ProgressBar")
@onready var barrier_bar = get_node("UI/ProgressBar2")

# Reference to the target marker node
@onready var target_marker = get_node("UI/TargetMarker")

# Exported variables
@export_group("Skills and Abilities")
@export var basic_attack_scene : PackedScene
@export var movement_skill_scene : PackedScene
@export var type : Array[String]
var movement_skill

# Player variables
var in_combat = false
var in_stealth = false
var melee = false
var gold = 0
var global_weight : float = 0
var global_movement_speed : float = 0
var global_evade : float = 0
var global_armor : float = 0
var global_strength : float = 0
var global_dexterity : float = 0
var global_intelligence : float = 0
var global_vitality : float = 0
var global_health_regen : float = 0
var global_mana_regen : float = 0
var global_stamina_regen : float = 0
var global_barrier_regen : float = 0
var global_health : float = 0
var global_barrier : float = 0
var global_mana : float = 0
var global_stamina : float = 0
var global_bleed_damage : float = 0
var global_burn_damage : float = 0
var global_freeze_effectiveness : float = 0
var global_heal_effectiveness : float = 0
var global_damage : float = 0

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
var current_ascension_currency = 0

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
	
# Called when the node is ready
func _ready():
	health_bar._update_health(_calculate_percentage(current_health, total_health))
	_update_stats()
	current_health = total_health
	current_mana = total_mana
	current_stamina = total_stamina
	current_barrier = total_barrier

	movement_skill = movement_skill_scene.instantiate()
	movement_skill.unit = self
	add_child(movement_skill)

# Process function called every frame
func _process(delta):
	if paused:
		return
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
		GameManager._change_scene("res://Scenes/Menu.tscn", true)
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
