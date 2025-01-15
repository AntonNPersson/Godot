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
var is_docile = true
signal level_enchant(tags, projectile_type)
			
#-------------------#
# Exported Variables
#-------------------#

enum targeting_type {Line, EnemyTarget, AllyTarget, Area, Passive, Self, Movement, EnemyAura, AllyAura, Summon, None}
enum area_types {Storm, Blast, Scream, Custom}
@export_group('Base')
@export var icon : Texture
@export var a_name : String
@export_multiline var tooltip_text : String
@export var mana_cost : float = 0
@export var cooldown : float
@export var _range : float
@export var projectile_type : targeting_type
@export var ability_type : String
@export_group('Sprite Settings')
@export var sprite_frames : SpriteFrames
@export var sprite_scale : float = 1
@export var sprite_offset : Vector2
@export_group('Projectile Settings')
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
@export var echo : float = 1
@export var area_pool : bool = false
@export var area_pool_damage : float
@export var area_pool_radius : float
@export_group('Target Settings')
@export var additional_targets : int = 1
@export var additional_self_target : bool = false
@export_group('Movement Settings')
@export var type : String
@export var movement_speed : float
@export var pool : bool
@export var custom_movement : bool
@export var custom_end : bool = false
@export var custom_start : bool = true
@export var charges : int = 1
@export_group("Passive Settings")
@export var auto_attack_based : bool
@export var auto_attack_interval : float
@export var toggle : bool
@export var toggle_state_count : int
@export var toggle_icons : Array[Texture]
var toggle_state = 0
@export_group('Summon Settings')
@export var summon_scene : PackedScene
@export var summon_amount : int
@export var summon_scaling : float
@export var unique : bool
var summon_instance
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
@export var weight_duration : float = 0.45
var tooltip : String
var secondary_tooltip : String
var ad_update : bool = false

var item_tags : Array[String]
var item_values : Array[float]
var item_duration : Array[float]
var item_color : Array[Color]
var item_cooldown : Array[float]
var item_timers : Array[float]
var item_unique : Array[bool]
var forced_closest : bool = false

var lowest_cooldown : float = 0
var non_hit_tags : Array[String]
var added_tags : Array[String]
var enchant_objects : Array[Node]

var enchants = {
	"Tags" : [],
	"Values" : [],
	"Types" : [],
	"Extra" : []
}
var enchant_timers : Array[float]

var power : float
var extra : Dictionary
#-------------------#
# Helper Functions
#-------------------#

func _process(delta):
	if is_docile:
		return

	if projectile_type == targeting_type.Area:
		sprite_scale = radius/(sprite_frames.get_frame_texture("default", 0).get_width())
	
	if cooldown < lowest_cooldown:
		cooldown = lowest_cooldown

	_update_tooltip()
	if projectile_type == targeting_type.EnemyAura or projectile_type == targeting_type.AllyAura:
		_apply_aura()

	if projectile_type == targeting_type.Passive:
		_update_passive()

	if ad_update:
		_advanced_update()

	for i in range(item_timers.size()):
		if item_timers[i] >= 0:
			item_timers[i] -= delta

# Update scaling of damage
func _apply_scaling(dmg, _type):
	var attribute_map = {
		'INT': unit.total_intelligence,
		'STR': unit.total_strength,
		'DEX': unit.total_dexterity
	}
	var extra_dmg = attribute_map[_type] * 0.15
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
	extra["ability"] = a_name
	extra["ability_instance"] = self
	for e in enchants["Extra"]:
		extra.merge(e)
	if projectile_type == targeting_type.EnemyAura:
		for child in get_tree().get_nodes_in_group('enemies'):
			if child.global_position.distance_to(unit.global_position) <= _range:
				for v in values.size():
					unit.get_node('Control').on_action.emit(values[v], child, unit, tags[v], extra)
			else:
				for v in values.size():
					unit.get_node('Control').on_action.emit(0, child, unit, tags[v], extra)
	elif projectile_type == targeting_type.AllyAura:
		for child in get_tree().get_nodes_in_group('players'):
			if child.global_position.distance_to(unit.global_position) <= _range:
				for v in values.size():
					unit.get_node('Control').on_action.emit(values[v], child, unit, tags[v], extra)
			else:
				for v in values.size():
					unit.get_node('Control').on_action.emit(0, child, unit, tags[v], extra)

# Update tooltip based on type of ability
func _update_tooltip():
	if unit == null:
		unit = get_tree().get_first_node_in_group('players')
	tooltip = tooltip_text + "\n\n"
	secondary_tooltip = ""
	if projectile_type == targeting_type.Passive and toggle:
		tooltip += "Current State: " + str(tags[toggle_state]) + "\n\n"

	if projectile_type == targeting_type.Summon:
		tooltip += "\nLevel: " + str(level)
		tooltip += " Cost: " + str(mana_cost)
		tooltip += " Cooldown: " + str(unit._apply_cooldown_reduction(cooldown)) + "s"
		tooltip += " Amount: " + str(summon_amount)
		tooltip += "\nType: " + str(ability_type)
		return

	unit._update_stats()

	var previous_objects = {}

	if enchant_objects.size() != 0:
		# Aggregate the values for each enchant object by a unique identifier
		for object in enchant_objects:
			var key = object.name if object.has_method("name") else str(object)

			if previous_objects.has(key):
				# Aggregate the values
				for t in range(object.values.size()):
					previous_objects[key]["values"][t] += object.values[t]
			else:
				# Initialize the tooltip data
				previous_objects[key] = {
					"tooltip": object._get_tooltip_2(),
					"values": object.values.duplicate()  # Create a copy of the values array
				}

		# Generate the final tooltips by replacing placeholders
		for key in previous_objects:
			var tooltip_data = previous_objects[key]
			var tooltip_text = tooltip_data["tooltip"]
			for t in range(tooltip_data["values"].size()):
				# Replace each value placeholder with the aggregated value
				tooltip_text = tooltip_text.replace("Value" + str(t), str(tooltip_data["values"][t]))
			tooltip += tooltip_text + "\n\n"


		
			
	if values.size() != 0:
		for i in range(0, values.size()):
			if tags[i] == "Damage":
				tooltip = tooltip.replace("Value" + str(i), str(ceil(_apply_scaling(values[i], ability_type))))
			if tags[i].find("Freeze"):
				if enchants["Tags"].find("FreezeDuration") != -1:
					tooltip = tooltip.replace("Value" + str(i), str(values[i] + enchants["Values"][enchants["Tags"].find("FreezeDuration")]))
			tooltip = tooltip.replace("Value" + str(i), str(values[i]))

	secondary_tooltip += "Level: " + str(level)
	secondary_tooltip += " Cost: " + str(mana_cost)
	if projectile_type != targeting_type.Passive or projectile_type != targeting_type.AllyAura or projectile_type != targeting_type.EnemyAura:
		if unit != null:
			secondary_tooltip += "\nCooldown: " + str(unit._apply_cooldown_reduction(cooldown)) + "s"
		else:
			secondary_tooltip += "\nCooldown: " + str(cooldown) + "s"
		secondary_tooltip += " Range: " + str(_range)
	if projectile_type == targeting_type.Area:
		secondary_tooltip += " Radius: " + str(radius)
	secondary_tooltip += "\nType: " + str(ability_type)
	secondary_tooltip += " Weight: " + str(weight)

# Add experience and level up
func _add_experience(value):
	current_experience += value
	if current_experience >= max_experience:
		_add_level()

func _reduce_cooldown(_amount):
	unit.get_node("InventoryManager")._reduce_cooldown(self, _amount)

func _reset_cooldown():
	unit.get_node("InventoryManager")._reset_cooldown(self)

func _reset_ability():
	for i in range(values.size()):
		values[i] -= increased_values[i] * (level - 1)
	for t in enchants["Tags"].size():
		if tags.find(enchants["Tags"][t]) != -1:
			_remove_tag(enchants["Tags"][t], enchants["Values"][t], enchants["Types"][t])
	enchants["Tags"].clear()
	enchants["Values"].clear()
	enchants["Types"].clear()
	enchants["Extra"].clear()
	added_tags.clear()
	enchant_objects.clear()

# Add level and update values
func _add_level():
	level += 1
	current_experience = 0.0
	max_experience += 100.0
	_level_grants()

# Add tag and value to ability
func _add_tag(tag, value, increased_value):
	if tags.find(tag) != -1:
		var index = tags.find(tag)
		values[index] += value
		increased_values[index] += increased_value
		return
	added_tags.append(tag)
	tags.append(tag)
	values.append(value)
	increased_values.append(increased_value)

func _has_added_tag(tag):
	if added_tags.find(tag) != -1:
		return true
	return false

func _remove_added_tag(tag):
	added_tags.erase(tag)

func _has_tag(tag):
	if tags.find(tag) != -1:
		return true
	return false

func _get_tag(tag):
	if tags.find(tag) != -1:
		return values[tags.find(tag)]
	return 0

func _remove_tag(tag, value, _type):
	var index = tags.find(tag)
	tags.erase(tag)
	values.remove_at(index)
	increased_values.remove_at(index)

func _add_enchant(tag, value, _type, extra = null, object = null):
	# When adding enchant don't forget that it's specific per ability when adding to combat manager. So check for tag + ability name.
	enchants["Tags"].append(tag)
	enchants["Values"].append(value)
	enchants["Types"].append(_type)
	enchants["Extra"].append(extra)
	enchant_objects.append(object)

	_add_tag(tag, value, 0)

	print("Enchanting" + tag)
	if "Hit" not in extra:
		non_hit_tags.append(tag)
		extra["ability"] = a_name
		extra["ability_instance"] = self
		unit.get_node('Control').on_action.emit(value, unit, self, tag, extra)

func _get_enchant_extras(tag):
	var index = enchants["Tags"].find(tag)
	return enchants["Extra"][index]

func _remove_all_enchants():
	for i in range(enchants["Tags"].size()):
		_remove_tag(enchants["Tags"][i], enchants["Values"][i], enchants["Types"][i])

func _add_item_tag(tag, value, dur, i_color, cd):
	item_tags.append(tag)
	item_values.append(value)
	item_duration.append(dur)
	item_color.append(i_color)
	item_cooldown.append(cd)
	item_timers.append(cd)


func _remove_item_tag(tag):
	var index = item_tags.find(tag)
	item_tags.erase(tag)
	item_values.remove_at(index)
	item_duration.remove_at(index)
	item_color.remove_at(index)
	item_cooldown.remove_at(index)
	item_timers.remove_at(index)
	item_unique.remove_at(index)

# Update values based on level
func _level_grants():
	if projectile_type == targeting_type.Summon:
		for summon in unit.get_node('Summons').get_children():
			summon._level_grants()
		return

	for inc in range(values.size()):
		values[inc] += increased_values[inc]

	if level % 3 == 0:
		level_enchant.emit(tags, projectile_type, self)

func _update_passive():
	extra["ability"] = a_name
	extra["ability_instance"] = self
	if auto_attack_based:
		extra["interval"] = auto_attack_interval
	if !toggle:
		for t in tags.size():
			unit.get_node('Control').on_action.emit(values[t], unit, unit, tags[t], extra)
	else:
		icon = toggle_icons[toggle_state]
		unit.get_node('Control').on_action.emit(values[toggle_state], unit, true, tags[toggle_state], extra)
		for t in range(toggle_state_count, tags.size()):
			unit.get_node('Control').on_action.emit(values[t], unit, true, tags[t], extra)

# Get closest visible enemy to mouse
func _get_closest_visible_enemy_to_mouse():
	var mouse_pos = unit.get_global_mouse_position()
	var closest_node = null
	var closest_distance = 99999999
	if unit.get_tree().get_nodes_in_group('enemies'):
		for child in unit.get_tree().get_nodes_in_group('enemies'):
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
	if unit.get_tree().get_nodes_in_group('players') or unit.get_tree().get_nodes_in_group('player_summon'):
		var appended_array = unit.get_tree().get_nodes_in_group('players') + unit.get_tree().get_nodes_in_group('player_summon')
		for child in appended_array:
			var distance = mouse_pos.distance_to(child.global_position)
		
			if distance < closest_distance:
				closest_distance = distance
				closest_node = child
	return closest_node

# Create light for ability
func _create_light(targett):
	var instance = load('res://Abilities/Utility/self_effect.tscn').instantiate()
	instance.get_child(0).color = light_color
	targett.add_child(instance)
	var timer
	if !is_buff:
		timer = Utility.get_node('TimerCreator')._create_timer(weight_duration, true, targett)
	else:
		timer = Utility.get_node('TimerCreator')._create_timer(buff_duration, true, targett)
	timer.timeout.connect(_remove_light.bind(instance, targett))
	timer.start()

func _create_light_specifics(targett, dura, color):
	var instance = load('res://Abilities/Utility/self_effect.tscn').instantiate()
	instance.get_child(0).color = color
	targett.add_child(instance)
	var timer
	timer = Utility.get_node('TimerCreator')._create_timer(dura, true, instance)
	timer.timeout.connect(_remove_light.bind(instance, targett))
	timer.start()

# Remove light from ability
func _remove_light(instance, targett):
	targett.remove_child(instance)
	instance.queue_free()

func _advanced_update():
	pass

#-------------------#
# Signals & Functions
#-------------------#
# Initialize ability, if needed. Some abilities might need to be initialized because of a specific value or tag
func _initialize():
	lowest_cooldown = cooldown * 0.3

	if projectile_type == targeting_type.Summon or is_docile or projectile_type == targeting_type.Passive:
		return
	extra["ability"] = a_name
	extra["ability_instance"] = self
	for e in enchants["Extra"]:
		extra.merge(e)
	for tag in tags.size():
		if "Duplicate" in tags[tag] or "Pierce" in tags[tag] or tags.find("Explosion") != -1 or "Echo" in tags[tag] or "AreaPool" in tags[tag] or "SelfTarget" in tags[tag] or "Multistrike" in tags[tag] or "MovementCharges" in tags[tag]:
			unit.get_node('Control').on_action.emit(values[tag], unit, self, tags[tag], extra)
	if advanced_update:
		ad_update = true

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
		if forced_closest:
			pos = _get_closest_visible_enemy_to_mouse().global_position
		for i in range(amount):
			var instance = load("res://Abilities/Utility/line_projectile.tscn").instantiate()
			instance.has_hit.connect(_on_hit)
			unit.get_tree().get_root().add_child(instance)
			instance.global_position = unit.global_position
			instance._start(pos, _range, speed, unit.global_position, sprite_frames, collision_radius, light_scale, light_color, sprite_scale, line_pierce, explosion, explosion_radius, self)
			await unit.get_tree().create_timer(0.1).timeout
	elif projectile_type == targeting_type.AllyTarget:
			target = _get_closest_visible_ally_to_mouse()
			if additional_targets <= 0:
				additional_targets = 1
			print(additional_targets)
			if !target or target.global_position.distance_to(unit.global_position) > _range:
				Utility.get_node("ErrorMessage")._create_error_message("No target in range.", unit)
				return false
			for i in range(additional_targets):
				print("Targeting")
				if i > 0:
					var new_target = _get_closest_visible_ally_to_target(target)
					target = new_target

				if sprite_frames != null:
					if target.has_node(a_name):
						target.get_node(a_name).queue_free()
					var animated_sprite = AnimatedSprite2D.new()
					target.add_child(animated_sprite)
					animated_sprite.name = a_name
					animated_sprite.sprite_frames = sprite_frames
					animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
					animated_sprite.global_position -= Vector2(0, 32)
					animated_sprite.play()
					animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(target))

				if additional_self_target and unit != target:
					_on_hit(unit)
					_create_light(unit)
					if sprite_frames != null:
						if unit.has_node(a_name):
							unit.get_node(a_name).queue_free()
						var animated_sprite = AnimatedSprite2D.new()
						unit.add_child(animated_sprite)
						animated_sprite.name = a_name
						animated_sprite.sprite_frames = sprite_frames
						animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
						animated_sprite.global_position -= Vector2(0, 32)
						animated_sprite.play()
						animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(unit))

				if explosion:
					var enemies = _get_allies_close_to_mouse()
					for enemy in enemies:
						_on_hit(enemy)
						_create_light(enemy)
						if sprite_frames != null:
							if enemy.has_node(a_name):
								enemy.get_node(a_name).queue_free()
							var animated_sprite = AnimatedSprite2D.new()
							enemy.add_child(animated_sprite)
							animated_sprite.name = a_name
							animated_sprite.sprite_frames = sprite_frames
							animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
							animated_sprite.global_position -= Vector2(0, 32)
							animated_sprite.play()
							animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(enemy))
				else:
					_on_hit(target)
					_create_light(target)
	elif projectile_type == targeting_type.EnemyTarget:
			target = _get_closest_visible_enemy_to_mouse()
			print("additional targets: " + str(additional_targets))
			if additional_targets <= 0:
				additional_targets = 1
			if !target or target.global_position.distance_to(unit.global_position) > _range:
				Utility.get_node("ErrorMessage")._create_error_message("No target in range.", unit)
				return false
			if _check_weight(false):
				unit.get_node('Control').on_action.emit(weight, unit, weight_duration, 'SpeedBuff')
			for i in range(additional_targets):
				if i > 0:
					var new_target = _get_closest_visible_enemy_to_target(target)
					target = new_target
				print("Targeting")
				if sprite_frames != null:
					if target.has_node(a_name):
						target.get_node(a_name).queue_free()
					var animated_sprite = AnimatedSprite2D.new()
					target.add_child(animated_sprite)
					animated_sprite.name = a_name
					animated_sprite.sprite_frames = sprite_frames
					animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
					animated_sprite.global_position -= Vector2(0, 32)
					animated_sprite.play()
					animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(target))
				if explosion:
					var enemies = _get_enemies_close_to_mouse()
					for enemy in enemies:
						_on_hit(enemy)
						_create_light(enemy)
						if sprite_frames != null:
							if enemy.has_node(a_name):
								enemy.get_node(a_name).queue_free()
							var animated_sprite = AnimatedSprite2D.new()
							enemy.add_child(animated_sprite)
							animated_sprite.name = a_name
							animated_sprite.sprite_frames = sprite_frames
							animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
							animated_sprite.global_position -= Vector2(0, 32)
							animated_sprite.play()
							animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(enemy))
				else:
					_on_hit(target)
					_create_light(target)
	elif projectile_type == targeting_type.Self:
		_on_hit(unit)
		_create_light(unit)
		if sprite_frames != null:
			if unit.has_node(a_name):
				unit.get_node(a_name).queue_free()
			var animated_sprite = AnimatedSprite2D.new()
			unit.add_child(animated_sprite)
			animated_sprite.name = a_name
			animated_sprite.sprite_frames = sprite_frames
			animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
			animated_sprite.global_position -= Vector2(0, 32)
			animated_sprite.play()
			animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(unit))
	elif projectile_type == targeting_type.Area:
		var current_values = values
		var pos = unit.get_global_mouse_position()
		for i in range(echo):
			if i > 0:
				await unit.get_tree().create_timer(1.8).timeout
			var instance = load("res://Abilities/Utility/area_projectile.tscn").instantiate()
			instance.has_hit.connect(_on_hit)
			unit.get_tree().get_root().add_child(instance)
			instance.global_position = unit.global_position
			instance._start(pos, _range, speed, unit, radius, duration, area_type, light_color, always_trigger, sprite_frames, sprite_scale, area_pool, area_pool_radius, i, self, sprite_offset)
			_shake_camera()
	elif projectile_type == targeting_type.Movement:
		if type == "Sprint":
			target = unit.get_global_mouse_position()
		else:
			target = _get_closest_visible_enemy_to_mouse()
		var instance = load("res://Abilities/Utility/movement_ability.tscn").instantiate()
		instance.has_hit.connect(_on_hit)
		unit.get_tree().get_root().add_child(instance)
		instance._start(unit, target, _range, movement_speed, type, light_color, explosion, explosion_radius, self, pool, sprite_frames, sprite_scale, custom_movement, custom_end, custom_start)
	elif projectile_type == targeting_type.Summon:
		for s in range(0, summon_amount):
			summon_instance = summon_scene.instantiate()
			summon_instance.obstacles_info = unit.obstacles_info
			summon_instance.do_action.connect(unit.get_node('Control')._on_action)	
			var number = 0
			for summon in unit.get_node('Summons').get_children():
				if summon_instance.u_name == summon.u_name:
					number += 1
					if number >= summon_amount:
						Utility.get_node("ErrorMessage")._create_error_message("Maximum summons on " + a_name + "reached.", unit)
						summon_instance.queue_free()
						return
			unit.get_node('Summons').add_child(summon_instance)
			summon_instance.global_position = unit.global_position
	elif projectile_type == targeting_type.Passive:
		if toggle:
			unit.get_node('Control').on_action.emit(values[toggle_state], unit, false, tags[toggle_state], extra)
			toggle_state += 1
			if toggle_state >= toggle_state_count:
				toggle_state = 0

	elif projectile_type == targeting_type.None:
		pass
	unit.current_mana -= mana_cost
	return true

func _remove_sprite_sheet(targett):
	if targett.has_node(a_name):
		targett.get_node(a_name).queue_free()
		print("Removing sprite sheet")

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
func _on_hit(area, extra = null):
	if extra == null:
		extra = {"ability": a_name,
				 "ability_instance": self}
	else:
		extra["ability"] = a_name
		extra["ability_instance"] = self
	
	var changed_values = []
	for val in values.size():
		changed_values.append(values[val])

	if "Pool" in extra:
		for v in changed_values.size():
			changed_values[v] = changed_values[v] * extra['Pool']
			print(changed_values[v])
			print("Pool")
	elif "Echo" in extra:
		for v in changed_values.size():
			changed_values[v] = changed_values[v] * extra['Echo']
			print(changed_values[v])
			print("Echo")

	for val in tags.size():
		if tags[val] in non_hit_tags or tags[val] == "Duplicate" or tags[val] == "Pierce" or tags[val] == "Explosion" or tags[val] == "Echo" or tags[val] == "AreaPool" or tags[val] == "SelfTarget":
			continue

		for e in range(enchants["Tags"].size()):
			if tags[val] in enchants["Tags"]:
				extra.merge(enchants["Extra"][e], true)

		if "Buff" in tags[val]:
			unit.get_node('Control').on_action.emit(changed_values[val], area, buff_duration, tags[val], extra)
		elif "Lifesteal" in tags[val]:
			unit.get_node('Control').on_action.emit(changed_values[tags.find("Damage")] * (values[val]/100), area, unit, tags[val])
		elif "Shock" in tags[val] or "Wind" in tags[val]:
			unit.get_node('Control').on_action.emit(changed_values[val], area, unit, tags[val])
		elif "QuickAttack" in tags[val]:
			var new_values = []
			var new_tags = []
			for i in range(values.size() - 2):
				new_values.append(values[i])
				new_tags.append(tags[i])
			unit.get_node('Control').on_action.emit(changed_values[val], new_values, unit, tags[val], new_tags)
		elif "Passive" in tags[val]:
			unit.get_node('Control').on_action.emit(changed_values[val], area, unit, tags[val], extra)
		elif "Damage" in tags[val]:
			unit.get_node('Control').on_action.emit(_apply_scaling(changed_values[val], ability_type), area, unit, tags[val])
			if unit.total_spell_vamp > 0:
				unit.get_node('Control').on_action.emit(_apply_scaling(changed_values[val], ability_type) * (unit.total_spell_vamp/100), unit, unit, "Heal")
			_shake_camera()
		else:
			unit.get_node('Control').on_action.emit(changed_values[val], area, unit, tags[val], extra)

func _on_item_use():
	if item_tags.size() == 0:
		return
	for val in range(item_timers.size()):
		if item_timers[val] <= 0:
			item_timers[val] = item_cooldown[val]
			_create_light_specifics(unit, item_duration[val], item_color[val])
			if "WindShout" in item_tags[val]:
				if get_tree().get_nodes_in_group('enemies'):
					for enemy in get_tree().get_nodes_in_group('enemies'):
						if enemy.global_position.distance_to(unit.global_position) < 130:
							unit.get_node('Control').on_action.emit(item_values[val], enemy, unit, "Wind")
			else:
				unit.get_node('Control').on_action.emit(item_values[val], unit, item_duration[val], item_tags[val], self)

# Set targeting to true/false
func _target(state):
	targeting = state

# Get targeting state
func _get_targeting():
	return targeting

func _get_closest_visible_ally_to_target(_target):
	var closest_node = null
	var closest_distance = 99999999
	if unit.get_tree().get_nodes_in_group('players') or unit.get_tree().get_nodes_in_group('player_summon'):
		var appended_array = unit.get_tree().get_nodes_in_group('players') + unit.get_tree().get_nodes_in_group('player_summon')
		for child in appended_array:
			var distance = _target.global_position.distance_to(child.global_position)
		
			if distance < closest_distance:
				closest_distance = distance
				closest_node = child
	return closest_node

func _get_closest_visible_enemy_to_target(_target):
	var closest_node = null
	var closest_distance = 99999999
	if unit.get_tree().get_nodes_in_group('enemies'):
		for child in unit.get_tree().get_nodes_in_group('enemies'):
			if child == _target:
				continue
			var distance = _target.global_position.distance_to(child.global_position)
		
			if distance < closest_distance:
				closest_distance = distance
				closest_node = child
	return closest_node

func _shake_camera():
	if GameManager.settings['screen_shake']:
		unit.get_node('Camera').shake_intensity = weight/25
		unit.get_node('Camera').shake_duration = weight_duration/2
		unit.get_node('Camera').is_shaking = true

func _get_ability_data():
	var data = {
		'name': a_name,
		'level': level,
		'type': ability_type,
		"enchant_tag": enchants["Tags"],
		"enchant_value": enchants["Values"],
		"enchant_type": enchants["Types"]
	}
	return data
