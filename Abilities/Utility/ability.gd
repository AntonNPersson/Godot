@tool
extends Node
class_name ability

# Tool/template to make an ability, this is the base class for all abilities and should be inherited from if needed, else it can be used as is.

#-------------------#
# Private Variables
#-------------------#

var unit
var target
var targeting = false
var target_marker
var level = 1
var current_experience = 0.0
var max_experience = 100.0
			
#-------------------#
# Exported Variables
#-------------------#

enum targeting_type {Line, EnemyTarget, AllyTarget, Area, Passive, Self, Movement, EnemyAura, AllyAura, None}
enum area_types {Storm, Blast, Scream}
@export_group('Base')
@export var icon : Texture
@export var a_name : String
@export_multiline var tooltip_text : String
@export var mana_cost : float = 0
@export var cooldown : float
@export var _range : float
@export var projectile_type : targeting_type
@export var ability_type : String
@export_group('Projectile Settings')
@export_subgroup('Sprite')
@export var sprite_frames : SpriteFrames
@export var sprite_scale : float = 1
@export_subgroup('Collision')
@export var collision_radius : float
@export_subgroup('Details')
@export var speed : float
@export var amount : float = 1
@export var line_pierce : bool = false
@export var explosion : bool = false
@export var explosion_radius : float
@export_group('Area Settings')
@export var area_type : area_types
@export var duration : float
@export var always_trigger : bool
@export var radius : float
@export_group('Movement Settings')
@export var type : String
@export var movement_speed : float
@export var pool : bool
@export_group('Tags & Values')
@export var tags : Array[String]
@export var values : Array[float]
@export var increased_values : Array[float]
@export_group('Extras')
@export var advanced_update : bool
@export var light_color : Color
@export var light_scale : float
@export var is_buff : bool = false
@export var buff_type : String
@export var buff_duration : float
@export var weight : float
@export var weight_duration : float = 0.55
var tooltip : String
var ad_update : bool = false

var item_tags : Array[String]
var item_values : Array[float]
var item_duration : Array[float]

var power : float
#-------------------#
# Helper Functions
#-------------------#

func _process(delta):
	_update_tooltip()
	if projectile_type == targeting_type.EnemyAura or projectile_type == targeting_type.AllyAura:
		_apply_aura()

	if ad_update:
		_advanced_update()
# Update scaling of damage
func _apply_scaling(dmg, type):
	if unit == null:
		return dmg
	var attribute_map = {
		'INT': unit.total_intelligence,
		'STR': unit.total_strength,
		'DEX': unit.total_dexterity
	}
	var extra_dmg = attribute_map[type] * 0.3
	return dmg + extra_dmg

func _calculate_power():
	if "Damage" in tags:
		power += values[tags.find("Damage")]
	if "Heal" in tags:
		power += values[tags.find("Heal")]
	if "Buff" in tags:
		if buff_type == "Percentage":
			power += values[tags.find("Buff")] * 100
		else:
			power += values[tags.find("Buff")]
	if "Lifesteal" in tags:
		power *= values[tags.find("Lifesteal")]/100
	if "QuickAttack" in tags:
		power += unit.total_attack_damage * values[tags.find("QuickAttack")]
	if "Duplicate" in tags:
		power += values[tags.find("Damage")] * values[tags.find("Duplicate")]
	power -= mana_cost * 2
	power -= cooldown * 100
	power += _range
	power += power * (unit.cooldown_reduction/100)
	power += power * (unit.double_cast_chance/100)
	power = _apply_scaling(power, ability_type)
	return power

func _apply_aura():
	if unit == null:
		return
	if projectile_type == targeting_type.EnemyAura:
		for child in get_tree().get_nodes_in_group('enemies'):
			if child.global_position.distance_to(unit.global_position) <= _range:
				_on_hit(child)
			else:
				for v in values.size():
					values[v] = -values[v]
				_on_hit(child)
	elif projectile_type == targeting_type.AllyAura:
		for child in get_tree().get_nodes_in_group('players'):
			if child.global_position.distance_to(unit.global_position) <= _range:
				_on_hit(child)
			else:
				for v in values.size():
					values[v] = -values[v]
				_on_hit(child)

# Update tooltip based on type of ability
func _update_tooltip():
	tooltip = tooltip_text + "\n\n"
	
	for i in range(tags.size()):
		tooltip += tags[i] + ": " + str(values[i]) + " "
		if tags[i] == 'Duplicate':
			tooltip += " + " + str(amount)
		if tags[i] == 'Damage':
			tooltip += " + " + str(_apply_scaling(values[i], ability_type) - values[i]) + " "
		if tags[i] == 'Stealth':
			tooltip += "s"

	tooltip += "\nLevel: " + str(level)
	tooltip += " Cost: " + str(mana_cost)
	if projectile_type != targeting_type.Passive or projectile_type != targeting_type.AllyAura or projectile_type != targeting_type.EnemyAura:
		if unit != null:
			tooltip += " Cooldown: " + str(unit._apply_cooldown_reduction(cooldown)) + "s"
		else:
			tooltip += " Cooldown: " + str(cooldown) + "s"
		tooltip += " Range: " + str(_range)
	if projectile_type == targeting_type.Area:
		tooltip += " Radius: " + str(radius)
	tooltip += "\nType: " + str(ability_type)
	tooltip += " Weight: " + str(weight)

# Add experience and level up
func _add_experience(value):
	current_experience += value
	if current_experience >= max_experience:
		_add_level()

# Add level and update values
func _add_level():
	level += 1
	current_experience = 0.0
	max_experience *= 2
	_level_grants()

# Add tag and value to ability
func _add_tag(tag, value, increased_value):
	tags.append(tag)
	values.append(value)
	increased_values.append(increased_value)

func _add_item_tag(tag, value, dur):
	item_tags.append(tag)
	item_values.append(value)
	item_duration.append(dur)

func _remove_item_tag(tag):
	var index = item_tags.find(tag)
	item_tags.erase(tag)
	item_values.remove_at(index)
	item_duration.remove_at(index)

# Update values based on level
func _level_grants():
	for inc in range(values.size()):
		values[inc] += increased_values[inc]

# Update passive abilities. If ability is passive, a new passive_ability class must be used, that inherits from this class
func _update_passive():
	pass

# Get closest visible enemy to mouse
func _get_closest_visible_enemy_to_mouse():
	var mouse_pos = unit.get_global_mouse_position()
	var closest_node = null
	var closest_distance = 99999999
	if get_tree().get_nodes_in_group('enemies'):
		for child in get_tree().get_nodes_in_group('enemies'):
			var distance = mouse_pos.distance_to(child.global_position)
		
			if distance < closest_distance:
				closest_distance = distance
				closest_node = child
	return closest_node

# Get closest visible ally to mouse
func _get_closest_visible_ally_to_mouse():
	var mouse_pos = unit.get_global_mouse_position()
	var closest_node = null
	var closest_distance = 99999999
	if get_tree().get_nodes_in_group('players'):
		for child in get_tree().get_nodes_in_group('players'):
			var distance = mouse_pos.distance_to(child.global_position)
		
			if distance < closest_distance:
				closest_distance = distance
				closest_node = child
	return closest_node

# Create light for ability
func _create_light(targett):
	var instance = load('res://Abilities/Utility/self_effect.tscn').instantiate()
	instance.get_child(0).color = light_color
	instance.get_child(1).color = light_color
	targett.add_child(instance)
	var timer
	if !is_buff:
		timer = Utility.get_node('TimerCreator')._create_timer(weight_duration, true, targett)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(buff_duration, true, targett)
	timer.timeout.connect(_remove_light.bind(instance, targett))
	timer.start()

# Remove light from ability
func _remove_light(instance, targett):
	targett.remove_child(instance)

func _advanced_update():
	pass

#-------------------#
# Signals & Functions
#-------------------#
# Initialize ability, if needed. Some abilities might need to be initialized because of a specific value or tag
func _initialize():
	for tag in tags.size():
		if "Duplicate" in tags[tag] or "Pierce" in tags[tag] or "Explosion" in tags[tag]:
			unit.get_node('Control').on_action.emit(values[tag], unit, self, tags[tag])
	if advanced_update:
		ad_update = true

	if projectile_type == targeting_type.Passive:
		_update_passive()

func _get_enemies_close_to_mouse():
	var mouse_pos = unit.get_global_mouse_position()
	var enemies = []
	if get_tree().get_nodes_in_group('enemies'):
		for child in get_tree().get_nodes_in_group('enemies'):
			var distance = mouse_pos.distance_to(child.global_position)
			if distance < explosion_radius:
				enemies.append(child)
	return enemies

func _get_allies_close_to_mouse():
	var mouse_pos = unit.get_global_mouse_position()
	var allies = []
	if get_tree().get_nodes_in_group('players'):
		for child in get_tree().get_nodes_in_group('players'):
			var distance = mouse_pos.distance_to(child.global_position)
			if distance < explosion_radius:
				allies.append(child)
	return allies

# Main function to use ability, it will check all the relevant exported variables and use the ability accordingly
func _use():
	_advanced_update()
	if _check_weight(true):
		unit.get_node('Control').on_action.emit(-(weight + unit.global_weight), unit, weight_duration, 'SpeedBuff')
		
	_on_item_use()

	if projectile_type == targeting_type.Line:
		var pos = unit.get_global_mouse_position()
		for i in range(amount):
			var instance = load("res://Abilities/Utility/line_projectile.tscn").instantiate()
			instance.has_hit.connect(_on_hit)
			unit.get_tree().get_root().add_child(instance)
			instance.global_position = unit.global_position
			instance._start(pos, _range, speed, unit.global_position, sprite_frames, collision_radius, light_scale, light_color, sprite_scale, line_pierce, explosion, explosion_radius, self)
			await get_tree().create_timer(0.1).timeout
	elif projectile_type == targeting_type.AllyTarget:
			target = _get_closest_visible_ally_to_mouse()
			if !target or target.global_position.distance_to(unit.global_position) > _range:
				Utility.get_node("ErrorMessage")._create_error_message("No target in range.", unit)
				return false
			if _check_weight(false):
				unit.get_node('Control').on_action.emit(weight, unit, weight_duration, 'SpeedBuff')
			if explosion:
				var enemies = _get_allies_close_to_mouse()
				for enemy in enemies:
					_on_hit(enemy)
					_create_light(enemy)
			else:
				_on_hit(target)
				_create_light(target)
	elif projectile_type == targeting_type.EnemyTarget:
			target = _get_closest_visible_enemy_to_mouse()
			if !target or target.global_position.distance_to(unit.global_position) > _range:
				Utility.get_node("ErrorMessage")._create_error_message("No target in range.", unit)
				return false
			if _check_weight(false):
				unit.get_node('Control').on_action.emit(weight, unit, weight_duration, 'SpeedBuff')
			if explosion:
				var enemies = _get_enemies_close_to_mouse()
				for enemy in enemies:
					_on_hit(enemy)
					_create_light(enemy)
			else:
				_on_hit(target)
				_create_light(target)
	elif projectile_type == targeting_type.Self:
		_on_hit(unit)
		_create_light(unit)
	elif projectile_type == targeting_type.Area:
		var pos = unit.get_global_mouse_position()
		for i in range(amount):
			var instance = load("res://Abilities/Utility/area_projectile.tscn").instantiate()
			instance.has_hit.connect(_on_hit)
			unit.get_tree().get_root().add_child(instance)
			instance.global_position = unit.global_position
			instance._start(pos, _range, speed, unit.global_position, radius, duration, area_type, light_color, always_trigger)
			await get_tree().create_timer(0.1).timeout
		_shake_camera()
	elif projectile_type == targeting_type.Movement:
		if type == "Sprint":
			target = unit.get_global_mouse_position()
		else:
			target = _get_closest_visible_enemy_to_mouse()
		var instance = load("res://Abilities/Utility/movement_ability.tscn").instantiate()
		instance.has_hit.connect(_on_hit)
		unit.get_tree().get_root().add_child(instance)
		instance._start(unit, target, _range, movement_speed, type, light_color, explosion, explosion_radius, self, pool)
	elif projectile_type == targeting_type.None:
		pass
	unit.current_mana -= mana_cost
	return true

func _check_weight(global):
	if !global:
		if weight > 0:
			return true
	else:
		if weight > 0 and projectile_type != targeting_type.EnemyTarget and projectile_type != targeting_type.AllyTarget:
			return true
	return false
	

func _is_only_one(arr : Array):
	var count = 0
	for elem in arr:
		if elem:
			count += 1
	if count == 1 or count == 0:
		return true
	return false

# Update targeting based on type of ability, abilitytargetsystem will use this to draw the targeting
func _update_targeting(_delta, _targeting_array, _targeting):
	_update_tooltip()
	if !_is_only_one(_targeting_array):
		return

	if projectile_type == targeting_type.Line:
		if _targeting:
			Utility.get_node('AbilityTargetSystem')._draw_line_targeting(unit, 16)
	elif projectile_type == targeting_type.AllyTarget:
		if _targeting:
			Utility.get_node('AbilityTargetSystem')._draw_target_targeting()
	elif projectile_type == targeting_type.EnemyTarget:
		if _targeting:
			Utility.get_node('AbilityTargetSystem')._draw_target_targeting()
	elif projectile_type == targeting_type.Area:
		if _targeting:
			Utility.get_node('AbilityTargetSystem')._draw_area_targeting(radius, _range, unit)
	elif projectile_type == targeting_type.Movement:
		if _targeting:
			if type == "Sprint":
				Utility.get_node('AbilityTargetSystem')._draw_line_targeting(unit, 16)
			else:
				Utility.get_node('AbilityTargetSystem')._draw_target_targeting()

# Hit function, this will be called when the ability hits something, no matter the type
func _on_hit(area):
	for val in tags.size():
		if "Buff" in tags[val]:
			unit.get_node('Control').on_action.emit(values[val], area, buff_duration, tags[val])
		elif "Lifesteal" in tags[val]:
			unit.get_node('Control').on_action.emit(values[tags.find("Damage")] * (values[val]/100), area, unit, tags[val])
		elif "Burn" in tags[val]:
			unit.get_node('Control').on_action.emit(values[tags.find("Damage")]/2, area, unit, tags[val])
		elif "Shock" in tags[val]:
			unit.get_node('Control').on_action.emit(values[val], area, unit, tags[val])
		elif "QuickAttack" in tags[val]:
			var new_values = []
			var new_tags = []
			for i in range(values.size() - 2):
				new_values.append(values[i])
				new_tags.append(tags[i])
			unit.get_node('Control').on_action.emit(values[val], new_values, unit, tags[val], new_tags)
		elif "Duplicate" in tags[val] or "Pierce" in tags[val] or "Explosion" in tags[val]:
			continue
		elif "Passive" in tags[val]:
			unit.get_node('Control').on_action.emit(values[val], area, unit, tags[val])
		else:
			unit.get_node('Control').on_action.emit(_apply_scaling(values[val], ability_type), area, unit, tags[val])
			if projectile_type != targeting_type.Area:
				_shake_camera()

func _on_item_use():
	if item_tags.size() == 0:
		return

	for val in item_tags.size():
		unit.get_node('Control').on_action.emit(item_values[val], unit, item_duration[val], item_tags[val])

# Set targeting to true/false
func _target(state):
	targeting = state

# Get targeting state
func _get_targeting():
	return targeting

func _shake_camera():
	if GameManager.settings['screen_shake']:
		unit.get_node('Camera').shake_intensity = weight/25
		unit.get_node('Camera').shake_duration = weight_duration/2
		unit.get_node('Camera').is_shaking = true

