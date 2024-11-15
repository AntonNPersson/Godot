# FILEPATH: /c:/Users/Anton/Documents/Godot/Units/Stats/creatureVariables.gd

extends Node2D
class_name creature_variables

# Signal emitted when an action is performed.
# Parameters:
# - value: The value of the action.
# - target: The target of the action.
# - unit: The unit performing the action.
# - tag: The tag associated with the action.
signal do_action(value, target, unit, tag, extra)

# Signal emitted when the unit is dead.
# Parameters:
# - unit: The unit that is dead.
signal is_dead(unit)

var dead = false
var obstacles_info: Node
var drop_info: Node
var summoned = false
var waves: Node
var enemy_layer = 1
var total_armor: float
var total_evade: float
var total_speed: float
var total_health: float
var total_range: float
var total_attack_speed: float
var total_attack_damage: float
var total_windup_time: float

# The name of the unit.
@export var u_name: String

@export var experience = 0

@export var ascension_currency = 0

# The base armor value.
@export var base_armor = 0

# The base evade value.
@export var base_evade = 0

# The base speed value.
@export var base_speed = 500

# The base health value.
@export var base_health = 100

# The base range value.
@export var base_range = 700

# The base attack speed value.
@export var base_attack_speed = 0.6

# The base attack damage value.
@export var base_attack_damage = 30

# The base windup time value.
@export var base_windup_time = 1.0

# An array of abilities as PackedScene.
@export var abilities: Array[PackedScene] = []

# The basic attack scene as PackedScene.
@export var basic_attack_scene: PackedScene

# The aggro range value.
@export var aggro_range: float = 100000

# The progress bar node.
@onready var bar = null

var has_aggro = false
@export var paused = false
var attack_modifier_tags = []
var attack_modifier_values = []
var bonus_armor = 0.0
var bonus_evade = 0.0
var bonus_speed = 0.0
var bonus_health = 0.0
var bonus_range = 0.0
var bonus_attack_speed = 0.0
var bonus_attack_damage = 0.0
var current_health = 100

var current_base_armor = 0.0
var current_base_evade = 0.0
var current_base_health = 0.0
var current_base_attack_speed = 0.0
var current_base_experience = 0.0
var current_base_ascension_currency = 0.0
var current_base_speed = 0.0
var current_base_range = 0.0
var current_base_attack_damage = 0.0

var is_stunned = false
var is_rooted = false
var is_summon = false
var is_taunted = false
var is_silenced = false
var is_frozen = false
var is_hovered = false
var is_colliding = false


var _target = null

var increased_amount = 1.0

func _ready():
	# Update the totals and set the current health.
	_ascend()
	current_base_speed = base_speed
	current_base_range = base_range
	current_base_attack_speed = base_attack_speed
	_update_totals()
	current_health = total_health
	
	# If the unit is not in the 'boss' group, get the progress bar node.
	if !self.is_in_group('boss'):
		bar = get_node('UI/ProgressBar')
	
	# Connect the _is_dead function to the is_dead signal.
	is_dead.connect(_is_dead)

func _is_dead(unit):
	# Set the 'dead' variable to true if the unit is dead.
	if unit == self:
		dead = true
		for child in get_children():
			child.queue_free()
		do_action.emit(current_base_experience, unit, unit, 'Experience')
		do_action.emit(int(ascension_currency * get_tree().get_nodes_in_group("players")[0].ascension_currency_multiplier), unit, unit, 'Ascension')
		if !unit.is_in_group('summon'):
			drop_info._drop_item(unit.global_position)

		var drop_charge = randi_range(0, 100)
		randomize()
		if unit.is_in_group('summon'):
			if drop_charge < get_tree().get_nodes_in_group("players")[0].total_charge_drop_chance * 2:
				get_tree().get_nodes_in_group("players")[0].get_node('InventoryManager')._on_potion_recharge_picked_up()
		else:
			if drop_charge < get_tree().get_nodes_in_group("players")[0].total_charge_drop_chance:
				get_tree().get_nodes_in_group("players")[0].get_node('InventoryManager')._on_potion_recharge_picked_up()
		queue_free()

func _calculate_health_percentage():
	# Calculate the health percentage.
	return (current_health / total_health) * 100

func _ascend():
	var power = get_tree().get_nodes_in_group("players")[0].power
	current_base_armor = base_armor * power
	current_base_evade = base_evade * power
	current_base_health = base_health * power
	current_base_attack_damage = base_attack_damage * power
	current_base_experience = experience * power
	current_base_ascension_currency = ascension_currency

func _add_stats(curse):
	if "increased_armor" in curse:
		current_base_armor = current_base_armor + (current_base_armor * (curse.increased_armor/100.0))
	if "increased_evade" in curse:
		current_base_evade = current_base_evade + (current_base_evade * (curse.increased_evade/100.0))
	if "increased_speed" in curse:
		current_base_speed = current_base_speed + (current_base_speed * (curse.increased_speed/100.0))
	if "increased_health" in curse:
		current_base_health = current_base_health + (current_base_health * (curse.increased_health/100.0))
	if "increased_range" in curse:
		current_base_range = current_base_range + (current_base_range * (curse.increased_range/100.0))
	if "increased_attack_speed" in curse:
		current_base_attack_speed = current_base_attack_speed + (current_base_attack_speed * (curse.increased_attack_speed/100.0))
	if "increased_attack_damage" in curse:
		current_base_attack_damage = current_base_attack_damage + (current_base_attack_damage * (curse.increased_attack_damage/100.0))
	if "increased_amount" in curse:
		increased_amount = increased_amount + (curse.increased_amount/100.0)
	
func _update_totals():
	# Update the total values based on the base values and bonuses.
	total_armor = current_base_armor + bonus_armor
	total_evade = current_base_evade + bonus_evade
	total_speed = current_base_speed + bonus_speed
	total_health = current_base_health + bonus_health
	total_range = current_base_range + bonus_range
	total_attack_speed = current_base_attack_speed + bonus_attack_speed
	total_attack_damage = current_base_attack_damage + bonus_attack_damage
	total_windup_time = base_windup_time / total_attack_speed

func _update_stats():
	pass

func _process(_delta):
	# Update the totals and the health bar if it exists.
	_update_totals()
	if bar != null:
		bar._update_health(_calculate_health_percentage())
		bar._update_name(u_name)

	if current_health > total_health:
		current_health = total_health

	if is_hovered:
		var new_material = get_node('AnimatedSprite2D').material.duplicate()
		get_node('AnimatedSprite2D').material = new_material
		get_node('AnimatedSprite2D').material.set_shader_parameter("hit_effect_color", Color.GREEN)
		get_node('AnimatedSprite2D').material.set_shader_parameter("hit_effect_intensity", 0.6)
	else:
		get_node('AnimatedSprite2D').material.set_shader_parameter("hit_effect_color", Color.RED)
		get_node('AnimatedSprite2D').material.set_shader_parameter("hit_effect_intensity", 0.0)
		
func _on_do_action(value, target, duration, tag, extra = null):
	# Emit the do_action signal with the provided parameters.
	_target = target
	do_action.emit(value * get_tree().get_nodes_in_group("players")[0].power, target, duration, tag)

func _level_grants():
	total_attack_damage += 5
	total_health += 10
	total_attack_speed += 0.1
