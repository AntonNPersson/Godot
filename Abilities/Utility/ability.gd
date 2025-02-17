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
signal _on_cast(ability)
			
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
@export var mana_cost_percentage : float = 0
@export var mana_cost_increase : float = 0
@export var mana_cost_percentage_increase : float = 0
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
@export var projectile_split : bool = false
@export var projectile_split_amount : int
@export var projectile_ricochet : bool = false
@export var projectile_ricochet_amount : int
@export var projectile_spread : bool = false
@export var explosion : bool = false
@export var explosion_radius : float
@export var projectile_channel : bool = false
@export var projectile_channel_interval : float
@export var projectile_channel_increasing_mana_cost : float = 0
@export var projectile_channel_increasing_damage : float = 0
@export var hit_allies : bool = false
@export var ally_tags : Array[int]
@export var multiple_hit : bool = false
@export var multiple_hit_interval : float = 0
@export_group('Area Settings')
@export var area_type : area_types
@export var duration : float
@export var area_ally_hit : bool = false
@export var ally_tags_area : Array[int]
@export var area_multiple_hit : bool = false
@export var area_multiple_hit_interval : float = 0
@export var always_trigger : bool
@export var radius : float
@export var echo : float = 1
@export var echo_delay : float = 1.8
@export var area_pool : bool = false
@export var area_pool_damage : float
@export var area_pool_radius : float
@export var area_channel : bool = false
@export var area_channel_interval : float
@export var area_channel_increasing_mana_cost : float = 0
@export var area_channel_increasing_damage : float = 0
@export_group('Target Settings')
@export var additional_targets : int = 1
@export var additional_self_target : bool = false
@export var swap_position : bool = false
@export_group("Aura Settings")
@export var aura_interval : float
@export var aura_toggle : bool
@export var aura_toggle_icons : Array[Texture]
var aura_toggled = false
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
@export var activatable : bool = false
@export var activatable_duration : float = 0
@export var activatable_cooldown : float = 0
var activatable_duration_timer : float = 0
var activatable_cooldown_timer : float = 0
@export_group('Summon Settings')
@export var summon_scene : PackedScene
@export var summon_amount : int
@export var summon_scaling : float
@export var is_totem : bool
@export var totem_duration : float
var summon_instance
var summon_extra_flat_health : float
var summon_extra_percentage_health : float
var summon_extra_flat_attack_damage : float
var summon_extra_percentage_attack_damage : float
var summon_extra_flat_armor : float
var summon_extra_percentage_armor : float
var summon_extra_flat_attack_speed : float
var summon_extra_flat_evade : float
var summon_extra_percentage_evade : float
var summon_extra_abilities : Array[PackedScene]
var summon_extra_percentage_burn_damage : float
var summon_extra_percentage_bleed_damage : float
var summon_extra_percentage_poison_damage : float
@export_group("Buff Settings")
@export var is_buff : bool = false
@export var buff_duration : float
@export var end_action : bool = false
@export var begin_action : bool = false
@export var end_action_tags : Array[int]
@export var begin_action_tags : Array[int]
@export var action_range : float
@export var action_spritesheet : SpriteFrames
@export_group('Tags & Values')
@export var tags : Array[String]
@export var values : Array[float]
@export var increased_values : Array[float]
@export_group('Extras')
@export var advanced_update : bool
@export var light_color : Color
@export var light_scale : float
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

var added_percentage_damage : float
var warrior_used_rage : bool = false

var enchants = {
	"Tags" : [],
	"Values" : [],
	"Types" : [],
	"Extra" : []
}
var enchant_timers : Array[float]

var power : float
var extra : Dictionary
var channeling : bool = false
var is_channel_ability : bool = false
var channel_timer : float = 9999
var channel_current_mana_cost : float = 0
var channel_current_damage : float = 0

var aura_timer : float = 0
#-------------------#
# Helper Functions
#-------------------#

func _process(delta):
	if is_docile:
		return
	
	if area_channel or projectile_channel:
		is_channel_ability = true

	if projectile_type == targeting_type.Area and sprite_frames != null:
		sprite_scale = radius/(sprite_frames.get_frame_texture("default", 0).get_width())
	
	if cooldown < lowest_cooldown:
		cooldown = lowest_cooldown

	_update_tooltip()
	if projectile_type == targeting_type.EnemyAura or projectile_type == targeting_type.AllyAura:
		if aura_toggle:
			if aura_toggled:
				icon = aura_toggle_icons[0]
			else:
				icon = aura_toggle_icons[1]

			aura_timer += delta
			if aura_timer >= aura_interval and aura_toggled:
				_apply_aura()
				aura_timer = 0
		else:
			aura_timer += delta
			if aura_timer >= aura_interval:
				_apply_aura()
				aura_timer = 0

	if projectile_type == targeting_type.Passive:
		_update_passive()
		if activatable:
			if activatable_duration_timer > 0:
				activatable_duration_timer -= delta
			if activatable_duration_timer <= 0:
				extra["PassiveActive"] = false
			if activatable_cooldown_timer > 0:
				activatable_cooldown_timer -= delta
			

	if ad_update:
		_advanced_update()

	for i in range(item_timers.size()):
		if item_timers[i] >= 0:
			item_timers[i] -= delta

	_update_channel(delta)

func _start_channel():
	channeling = true
	unit.is_rooted = true

func _stop_channel():
	channeling = false
	unit.is_rooted = false
	channel_timer = 9999
	channel_current_mana_cost = 0
	channel_current_damage = 0

func _update_channel(delta):
	if unit.current_mana < mana_cost:
		_stop_channel()
		return
	
	channel_timer += delta
	if projectile_type == targeting_type.Line:
		if channel_timer < projectile_channel_interval:
			return
	elif projectile_type == targeting_type.Area:
		if channel_timer < area_channel_interval:
			return
	channel_timer = 0

	if channeling:
		if projectile_type == targeting_type.Line:
			channel_current_mana_cost += projectile_channel_increasing_mana_cost
			var pos = unit.get_global_mouse_position()
			if forced_closest:
				pos = _get_closest_visible_enemy_to_mouse().global_position
			for i in range(amount):
				var instance = load("res://Abilities/Utility/line_projectile.tscn").instantiate()
				instance.has_hit.connect(_on_hit)
				unit.get_tree().get_root().add_child(instance)
				instance.global_position = unit.global_position
				instance._start(pos, _range, speed, unit.global_position, sprite_frames, collision_radius, light_scale, light_color, sprite_scale, line_pierce, explosion, explosion_radius, self, hit_allies, multiple_hit, multiple_hit_interval, projectile_ricochet, projectile_ricochet_amount, projectile_split, projectile_split_amount)
				await unit.get_tree().create_timer(0.1).timeout
			unit.current_mana -= mana_cost * (1 + channel_current_mana_cost/100.0)
			unit.current_mana -= (unit.total_mana * (mana_cost_percentage/100.0)) * (1 + channel_current_mana_cost/100.0)
			return

		if projectile_type == targeting_type.Area:
			channel_current_mana_cost += area_channel_increasing_mana_cost
			var pos = unit.get_global_mouse_position()
			for i in range(echo):
				if i > 0:
					await unit.get_tree().create_timer(echo_delay).timeout
					if _check_weight(true):
						unit.get_node('Control').on_action.emit(-(weight + unit.global_weight), unit, weight_duration, 'SpeedBuff')
				var instance = load("res://Abilities/Utility/area_projectile.tscn").instantiate()
				instance.has_hit.connect(_on_hit)
				unit.get_tree().get_root().add_child(instance)
				instance.global_position = unit.global_position
				instance._start(pos, _range, speed, unit, radius, duration, area_type, light_color, always_trigger, sprite_frames, sprite_scale, area_pool, area_pool_radius, i, self, sprite_offset, area_ally_hit, area_multiple_hit, area_multiple_hit_interval)
				_shake_camera()
			unit.current_mana -= mana_cost * (1 + channel_current_mana_cost/100.0)
			unit.current_mana -= (unit.total_mana * (mana_cost_percentage/100.0)) * (1 + channel_current_mana_cost/100.0)
			return
# Update scaling of damage
func _apply_scaling(dmg, _type):
	var attribute_map = {
		'INT': unit.total_intelligence,
		'STR': unit.total_strength,
		'DEX': unit.total_dexterity
	}
	var extra_dmg = (attribute_map[_type] * 0.15)
	if channeling:
		if projectile_channel:
			channel_current_damage += projectile_channel_increasing_damage/100.0
		if area_channel:
			channel_current_damage += area_channel_increasing_damage/100.0
	var total_percent_damage = (1 + (added_percentage_damage/100.0 + unit.global_damage/100.0 + channel_current_damage/100.0))
	return (dmg + extra_dmg) * total_percent_damage

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func highlight_word_with_color(input_text: String, word: String, color: String) -> String:
	var bbcode_template = "[color=" + color + "]" + word + "[/color]"
	var highlighted_text = input_text.replace(word, bbcode_template)
	return highlighted_text

func _calculate_power():
	if "Damage" in tags:
		power += values[tags.find("Damage")]
	if "Heal" in tags:
		power += values[tags.find("Heal")]
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
				if unit.current_mana < mana_cost:
					return
				_on_hit(child)
	elif projectile_type == targeting_type.AllyAura:
		for child in get_tree().get_nodes_in_group('players'):
			if child.global_position.distance_to(unit.global_position) <= _range:
				if unit.current_mana < mana_cost:
					return
				_on_hit(child)
		for summon in get_tree().get_nodes_in_group("player_summon"):
			if summon.global_position.distance_to(unit.global_position) <= _range:
				if unit.current_mana < mana_cost:
					return
				_on_hit(summon)
	
	if sprite_frames != null:
		if target.has_node(a_name):
			target.get_node(a_name).queue_free()
		var animated_sprite = AnimatedSprite2D.new()
		target.add_child(animated_sprite)
		animated_sprite.z_index = 1
		animated_sprite.name = a_name
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
		animated_sprite.global_position -= Vector2(0, 32)
		animated_sprite.play()
		animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(target))
	unit.current_mana -= mana_cost
	if aura_toggle:
		if unit.current_mana < mana_cost:
			aura_toggled = false

# Update tooltip based on type of ability
func _update_tooltip():
	if unit == null:
		unit = get_tree().get_first_node_in_group('players')
	tooltip = tooltip_text + "\n\n"
	secondary_tooltip = ""
	if projectile_type == targeting_type.Passive and toggle:
		tooltip += "Current State: " + str(tags[toggle_state]) + "\n\n"

	if projectile_type == targeting_type.Summon:
		secondary_tooltip += "Level: " + str(level)
		secondary_tooltip += " Cost: " + str(mana_cost + (unit.total_mana * (mana_cost_percentage/100.0)))
		secondary_tooltip += " Cooldown: " + str(unit._apply_cooldown_reduction(cooldown)) + "s"
		secondary_tooltip += " Amount: " + str(summon_amount)
		secondary_tooltip += "\nType: " + str(ability_type)

	tooltip = highlight_word_with_color(tooltip, "attack speed", "orange")
	tooltip = highlight_word_with_color(tooltip, "attack speed.", "orange")
	tooltip = highlight_word_with_color(tooltip, "attack damage", "mistyrose")
	tooltip = highlight_word_with_color(tooltip, "attack damage.", "mistyrose")
	tooltip = highlight_word_with_color(tooltip, "Damage ", "mistyrose")
	tooltip = highlight_word_with_color(tooltip, "Burn ", "tomato")
	tooltip = highlight_word_with_color(tooltip, "Freeze ", "deepskyblue")
	tooltip = highlight_word_with_color(tooltip, "Freezing ", "deepskyblue")
	tooltip = highlight_word_with_color(tooltip, "Frozen ", "slateblue")
	tooltip = highlight_word_with_color(tooltip, "Heal ", "greenyellow")
	tooltip = highlight_word_with_color(tooltip, "Healing ", "greenyellow")
	tooltip = highlight_word_with_color(tooltip, "Bleed ", "crimson")
	tooltip = highlight_word_with_color(tooltip, "Lifesteal ", "firebrick")
	tooltip = highlight_word_with_color(tooltip, "Stun ", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "Root ", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "Stunned ", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "Stunning ", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "Rooted ", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "Rooting ", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "burn", "tomato")
	tooltip = highlight_word_with_color(tooltip, "damage", "mistyrose")
	tooltip = highlight_word_with_color(tooltip, "freeze ", "deepskyblue")
	tooltip = highlight_word_with_color(tooltip, "freeze.", "deepskyblue")
	tooltip = highlight_word_with_color(tooltip, "freezing ", "deepskyblue")
	tooltip = highlight_word_with_color(tooltip, "freezing.", "deepskyblue")
	tooltip = highlight_word_with_color(tooltip, "frozen", "slateblue")
	tooltip = highlight_word_with_color(tooltip, "heal ", "greenyellow")
	tooltip = highlight_word_with_color(tooltip, "heal.", "greenyellow")
	tooltip = highlight_word_with_color(tooltip, "healing ", "greenyellow")
	tooltip = highlight_word_with_color(tooltip, "healing.", "greenyellow")
	tooltip = highlight_word_with_color(tooltip, "bleed", "crimson")
	tooltip = highlight_word_with_color(tooltip, "lifesteal ", "firebrick")
	tooltip = highlight_word_with_color(tooltip, "lifesteal.", "firebrick")
	tooltip = highlight_word_with_color(tooltip, "lifestealing ", "firebrick")
	tooltip = highlight_word_with_color(tooltip, "lifestealing.", "firebrick")
	tooltip = highlight_word_with_color(tooltip, "stun ", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "stun.", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "stunned ", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "stunned.", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "stunning ", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "stunning.", "goldenrod")
	tooltip = highlight_word_with_color(tooltip, "root ", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "root.", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "rooted ", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "rooted.", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "rooting ", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "rooting.", "olivedrab")
	tooltip = highlight_word_with_color(tooltip, "poisoning.", "yellowgreen")
	tooltip = highlight_word_with_color(tooltip, "poisoning", "yellowgreen")
	tooltip = highlight_word_with_color(tooltip, "poisoned.", "yellowgreen")
	tooltip = highlight_word_with_color(tooltip, "poisoned", "yellowgreen")
	tooltip = highlight_word_with_color(tooltip, "poison.", "yellowgreen")
	tooltip = highlight_word_with_color(tooltip, "poison", "yellowgreen")
	tooltip = highlight_word_with_color(tooltip, "evading.", "lawngreen")
	tooltip = highlight_word_with_color(tooltip, "evading", "lawngreen")
	tooltip = highlight_word_with_color(tooltip, "evade.", "lawngreen")
	tooltip = highlight_word_with_color(tooltip, "evade", "lawngreen")
	tooltip = highlight_word_with_color(tooltip, "movement speed.", "skyblue")
	tooltip = highlight_word_with_color(tooltip, "movement speed", "skyblue")
	tooltip = highlight_word_with_color(tooltip, "quick attacks", "darkseagreen")
	tooltip = highlight_word_with_color(tooltip, "quick attacks.", "darkseagreen")
	tooltip = highlight_word_with_color(tooltip, "quick attack", "darkseagreen")
	tooltip = highlight_word_with_color(tooltip, "quick attack.", "darkseagreen")
	tooltip = highlight_word_with_color(tooltip, "basic attacks", "burlywood")
	tooltip = highlight_word_with_color(tooltip, "basic attacks.", "burlywood")
	tooltip = highlight_word_with_color(tooltip, "basic attack", "burlywood")
	tooltip = highlight_word_with_color(tooltip, "basic attack.", "burlywood")
	tooltip = highlight_word_with_color(tooltip, "attack targets", "burlywood")
	tooltip = highlight_word_with_color(tooltip, "attack targets.", "burlywood")
	tooltip = highlight_word_with_color(tooltip, "attack target.", "burlywood")
	tooltip = highlight_word_with_color(tooltip, "attack target", "burlywood")
	tooltip = highlight_word_with_color(tooltip, "critical", "yellow")
	tooltip = highlight_word_with_color(tooltip, "critical.", "yellow")
	tooltip = highlight_word_with_color(tooltip, "critical strike", "yellow")
	tooltip = highlight_word_with_color(tooltip, "critical strike.", "yellow")
	tooltip = highlight_word_with_color(tooltip, "strength", "orangered")
	tooltip = highlight_word_with_color(tooltip, "strength.", "orangered")
	tooltip = highlight_word_with_color(tooltip, "dexterity", "lightgreen")
	tooltip = highlight_word_with_color(tooltip, "dexterity.", "lightgreen")
	tooltip = highlight_word_with_color(tooltip, "intelligence", "royalblue")
	tooltip = highlight_word_with_color(tooltip, "intelligence.", "royalblue")
	
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
				tooltip = tooltip.replace("Value" + str(i), str(round_to_dec(_apply_scaling(values[i], ability_type), 1)))
			if tags[i].find("Freeze"):
				if enchants["Tags"].find("FreezeDuration") != -1:
					tooltip = tooltip.replace("Value" + str(i), str(values[i] + enchants["Values"][enchants["Tags"].find("FreezeDuration")]))
			tooltip = tooltip.replace("Value" + str(i), str(values[i]))

	if projectile_type != targeting_type.Summon:
		secondary_tooltip += "Level: " + str(level)
		secondary_tooltip += " Cost: " + str(mana_cost + (unit.total_mana * (mana_cost_percentage/100.0)))
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

func _add_enchant(tag, value, _type, _extra = null, object = null):
	# When adding enchant don't forget that it's specific per ability when adding to combat manager. So check for tag + ability name.
	enchants["Tags"].append(tag)
	enchants["Values"].append(value)
	enchants["Types"].append(_type)
	enchants["Extra"].append(_extra)
	enchant_objects.append(object)

	_add_tag(tag, value, 0)
	
	if "Effect" in _extra:
		extra["Effect"] = _extra["Effect"]

	if "Never" in _extra:
		non_hit_tags.append(tag)
		extra["ability"] = a_name
		extra["ability_instance"] = self
		return

	if "Hit" not in _extra:
		non_hit_tags.append(tag)
		extra["ability"] = a_name
		extra["ability_instance"] = self
		unit.get_node('Control').on_action.emit(value, unit, self, tag, _extra)

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

	for inc in range(values.size()):
		values[inc] += increased_values[inc]

	mana_cost += mana_cost_increase
	mana_cost_percentage += mana_cost_percentage_increase

	if level % 3 == 0:
		level_enchant.emit(tags, projectile_type, self)

func _update_passive():
	extra["ability"] = a_name
	extra["ability_instance"] = self
	if auto_attack_based:
		extra["interval"] = auto_attack_interval

	if !toggle:
		for t in tags.size():
			if tags[t] == "PassiveActivate":
				continue
			var changed_value = values[t]
			if activatable:
				if extra.has("PassiveActive"):
					if extra["PassiveActive"]:
						changed_value = values[t] * 2
			unit.get_node('Control').on_action.emit(changed_value, unit, unit, tags[t], extra)
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

func _get_closest_enemy():
	var closest_node = null
	var closest_distance = 99999999
	if unit.get_tree().get_nodes_in_group('enemies'):
		for child in unit.get_tree().get_nodes_in_group('enemies'):
			var distance = unit.global_position.distance_to(child.global_position)
		
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
	if is_buff:
		extra["Duration"] = buff_duration
	for e in enchants["Extra"]:
		extra.merge(e)
	for tag in tags.size():
		if "Duplicate" in tags[tag] or "Pierce" in tags[tag] or "Explosion" in tags[tag] or "Echo" in tags[tag] or "AreaPool" in tags[tag] or "SelfTarget" in tags[tag] or "Multistrike" in tags[tag] or "MovementCharges" in tags[tag] or "Summon" in tags[tag] or "Ricochet" in tags[tag] or "Split" in tags[tag] or "Swap" in tags[tag]:
			unit.get_node('Control').on_action.emit(values[tag], unit, self, tags[tag], extra)
			non_hit_tags.append(tags[tag])
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
	print("Using ability: " + a_name)
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
			instance._start(pos, _range, speed, unit.global_position, sprite_frames, collision_radius, light_scale, light_color, sprite_scale, line_pierce, explosion, explosion_radius, self, hit_allies, multiple_hit, multiple_hit_interval, projectile_ricochet, projectile_ricochet_amount, projectile_split, projectile_split_amount)
			await unit.get_tree().create_timer(0.1).timeout
	elif projectile_type == targeting_type.AllyTarget:
			target = _get_closest_visible_ally_to_mouse()
			var current_player_position = unit.global_position
			if swap_position and target:
				unit.global_position = target.global_position
				target.global_position = current_player_position

			if additional_targets <= 0:
				additional_targets = 1
			if !target or target.global_position.distance_to(unit.global_position) > _range:
				Utility.get_node("ErrorMessage")._create_error_message("No target in range.", unit)
				return false
			for i in range(additional_targets):
				if i > 0:
					var new_target = _get_closest_visible_ally_to_target(target)
					target = new_target
					if swap_position and target:
						target.global_position = current_player_position

				if sprite_frames != null:
					if target.has_node(a_name):
						target.get_node(a_name).queue_free()
					var animated_sprite = AnimatedSprite2D.new()
					target.add_child(animated_sprite)
					animated_sprite.z_index = 1
					animated_sprite.name = a_name
					animated_sprite.sprite_frames = sprite_frames
					animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
					animated_sprite.global_position -= Vector2(0, 32) + sprite_offset
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
						animated_sprite.z_index = 1
						animated_sprite.name = a_name
						animated_sprite.sprite_frames = sprite_frames
						animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
						animated_sprite.global_position -= Vector2(0, 32) + sprite_offset
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
							animated_sprite.z_index = 1
							animated_sprite.name = a_name
							animated_sprite.sprite_frames = sprite_frames
							animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
							animated_sprite.global_position -= Vector2(0, 32) + sprite_offset
							animated_sprite.play()
							animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(enemy))
				else:
					_on_hit(target)
					_create_light(target)
	elif projectile_type == targeting_type.EnemyTarget:
			target = _get_closest_visible_enemy_to_mouse()
			var current_player_position = unit.global_position
			if swap_position and target:
				unit.global_position = target.global_position
				target.global_position = current_player_position

			if additional_targets <= 0:
				additional_targets = 1
			if !target or target.global_position.distance_to(unit.global_position) > _range:
				Utility.get_node("ErrorMessage")._create_error_message("No target in range.", unit)
				return false
			if _check_weight(true):
				unit.get_node('Control').on_action.emit(-(weight + unit.global_weight), unit, weight_duration, 'SpeedBuff')
			for i in range(additional_targets):
				if i > 0:
					var new_target = _get_closest_visible_enemy_to_target(target)
					target = new_target
					if swap_position and target:
						target.global_position = current_player_position
				if sprite_frames != null:
					if target.has_node(a_name):
						target.get_node(a_name).queue_free()
					var animated_sprite = AnimatedSprite2D.new()
					target.add_child(animated_sprite)
					animated_sprite.z_index = 1
					animated_sprite.name = a_name
					animated_sprite.sprite_frames = sprite_frames
					animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
					animated_sprite.global_position -= Vector2(0, 32) + sprite_offset
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
							animated_sprite.z_index = 1
							animated_sprite.name = a_name
							animated_sprite.sprite_frames = sprite_frames
							animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
							animated_sprite.global_position -= Vector2(0, 32) + sprite_offset
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
			animated_sprite.z_index = 1
			animated_sprite.name = a_name
			animated_sprite.sprite_frames = sprite_frames
			animated_sprite.scale = Vector2(sprite_scale, sprite_scale)
			animated_sprite.global_position -= Vector2(0, 32) + sprite_offset
			animated_sprite.play()
			animated_sprite.animation_finished.connect(_remove_sprite_sheet.bind(unit))
	elif projectile_type == targeting_type.Area:
		var current_values = values
		var pos = unit.get_global_mouse_position()
		for i in range(echo):
			if i > 0:
				await unit.get_tree().create_timer(echo_delay).timeout
				if _check_weight(true):
					unit.get_node('Control').on_action.emit(-(weight + unit.global_weight), unit, weight_duration, 'SpeedBuff')
			var instance = load("res://Abilities/Utility/area_projectile.tscn").instantiate()
			instance.has_hit.connect(_on_hit)
			unit.get_tree().get_root().add_child(instance)
			instance.global_position = unit.global_position
			instance._start(pos, _range, speed, unit, radius, duration, area_type, light_color, always_trigger, sprite_frames, sprite_scale, area_pool, area_pool_radius, i, self, sprite_offset, area_ally_hit, area_multiple_hit, area_multiple_hit_interval)
			_shake_camera()
	elif projectile_type == targeting_type.Movement:
		if type == "Teleport":
			target = unit.get_global_mouse_position()
		elif type == "Sprint":
			target = unit.get_node("Control").movement_target
		else:
			target = _get_closest_visible_enemy_to_mouse()
		var instance = load("res://Abilities/Utility/movement_ability.tscn").instantiate()
		instance.has_hit.connect(_on_hit)
		unit.get_tree().get_root().add_child(instance)
		instance._start(unit, target, _range, movement_speed, type, light_color, explosion, explosion_radius, self, pool, sprite_frames, sprite_scale, custom_movement, custom_end, custom_start)
	elif projectile_type == targeting_type.Summon:
		for summon in unit.get_node('Summons').get_children():
			if summon_instance.u_name == summon.u_name:
				summon.queue_free()
		for s in range(0, summon_amount):
			summon_instance = summon_scene.instantiate()
			summon_instance.obstacles_info = unit.obstacles_info
			summon_instance.do_action.connect(unit.get_node('Control')._on_action)
			for l in range(level - 1):
				summon_instance._level_grants(summon_scaling)

			if is_totem:
				for l in range(level - 1):
					summon_instance._totem_level_grants()
			summon_instance.bonus_health += summon_extra_flat_health
			summon_instance.bonus_health += (1 + summon_extra_percentage_health/100.0) * summon_instance.total_health
			summon_instance.bonus_attack_damage += summon_extra_flat_attack_damage
			summon_instance.bonus_attack_damage += (1 + summon_extra_percentage_attack_damage/100.0) * summon_instance.total_attack_damage
			summon_instance.bonus_attack_speed += summon_extra_flat_attack_speed
			summon_instance.bonus_armor += summon_extra_flat_armor
			summon_instance.bonus_armor += (1 + summon_extra_percentage_armor/100.0) * summon_instance.total_armor
			summon_instance.bonus_evade += summon_extra_flat_evade
			summon_instance.bonus_evade += (1 + summon_extra_percentage_evade/100.0) * summon_instance.total_evade
			summon_instance.abilities.append_array(summon_extra_abilities)
			summon_instance.globals["Burn"] += summon_extra_percentage_burn_damage
			summon_instance.globals["Bleed"] += summon_extra_percentage_bleed_damage
			summon_instance.globals["Poison"] += summon_extra_percentage_poison_damage
			unit.get_node('Summons').add_child(summon_instance)
			summon_instance.global_position = unit.global_position
			summon_instance.is_totem = is_totem
			summon_instance.totem_duration = totem_duration
			summon_instance._initialize_player_summon()
			summon_instance._update_totals()
	elif projectile_type == targeting_type.Passive:
		if activatable:
			if activatable_cooldown_timer <= 0:
				extra["PassiveActive"] = true
				activatable_duration_timer = activatable_duration
				activatable_cooldown_timer = activatable_cooldown
			else:
				Utility.get_node("ErrorMessage")._create_error_message("Ability on cooldown.", unit)

		if toggle:
			unit.get_node('Control').on_action.emit(values[toggle_state], unit, false, tags[toggle_state], extra)
			toggle_state += 1
			if toggle_state >= toggle_state_count:
				toggle_state = 0
		return
	elif projectile_type == targeting_type.AllyAura:
		if aura_toggle:
			if aura_toggled:
				aura_toggled = false
				return
			aura_toggled = true
		return
	elif projectile_type == targeting_type.EnemyAura:
		if aura_toggle:
			if aura_toggled:
				aura_toggled = false
				return
			aura_toggled = true
		return
	elif projectile_type == targeting_type.None:
		pass
	_on_cast.emit(self)
	unit.current_mana -= mana_cost + (unit.total_mana * (mana_cost_percentage/100.0))
	return true

func _remove_sprite_sheet(targett, name = ""):
	if targett.has_node(a_name):
		targett.get_node(a_name).queue_free()

	if name != "":
		if targett.has_node(name):
			targett.get_node(name).queue_free()

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

func _action_(targett, name):
	if targett.has_node(name):
		targett.get_node(name).queue_free()
	if end_action:
		print("End action")
		for enemy in get_tree().get_nodes_in_group('enemies'):
			if enemy.global_position.distance_to(unit.global_position) < action_range:
				for e in end_action_tags: 
					unit.get_node('Control').on_action.emit(values[e], enemy, unit, tags[e], extra)
	if begin_action:
		for enemy in get_tree().get_nodes_in_group('enemies'):
			if enemy.global_position.distance_to(unit.global_position) < action_range:
				for e in begin_action_tags:
					unit.get_node('Control').on_action.emit(values[e], enemy, unit, tags[e], extra)

func _end_or_begin_action():
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.name = "Action"
	unit.add_child(animated_sprite)
	animated_sprite.z_index = 1
	animated_sprite.sprite_frames = action_spritesheet
	animated_sprite.scale = Vector2(1, 1)
	animated_sprite.play()
	animated_sprite.animation_finished.connect(_action_.bind(unit, "Action"))

func _on_hit(area, extra = null):
	if extra == null:
		extra = {"ability": a_name,
				 "ability_instance": self}
	else:
		extra["ability"] = a_name
		extra["ability_instance"] = self

	
	var changed_values = []
	var changed_tags = []
	for val in values.size():
		changed_values.append(values[val])
		changed_tags.append(tags[val])
		
	if is_buff:
		extra["Duration"] = buff_duration
		if end_action:
			print("End action")
			var timer = Utility.get_node('TimerCreator')._create_timer(buff_duration, true, unit)
			timer.timeout.connect(_end_or_begin_action)
			timer.start()
			for e in end_action_tags:
				changed_tags.remove_at(e)
				changed_values.remove_at(e)
		if begin_action:
			_end_or_begin_action()
			for e in begin_action_tags:
				changed_tags.remove_at(e)
				changed_values.remove_at(e)

	if "Ally Hit" in extra and extra["Ally Hit"]:
		if area_ally_hit:
			for t in tags.size():
				if ally_tags_area.find(t) == -1:
					changed_values.remove_at(t)
					changed_tags.remove_at(t)
		if hit_allies:
			for t in tags.size():
				if ally_tags_area.find(t) == -1:
					changed_values.remove_at(t)
					changed_tags.remove_at(t)
	else:
		if area_ally_hit:
			for t in tags.size():
				for a in ally_tags_area:
					if t == a:
						changed_values.remove_at(t)
						changed_tags.remove_at(t)
		if hit_allies:
			for t in tags.size():
				for a in ally_tags:
					if t == a:
						changed_values.remove_at(t)
						changed_tags.remove_at(t)

	if GameManager.selected_character_name == "Warrior" and unit.current_rage - mana_cost > 0 and projectile_type != targeting_type.Self and projectile_type != targeting_type.AllyTarget:
		added_percentage_damage += mana_cost
		unit.current_rage -= mana_cost
		warrior_used_rage = true

	if "Pool" in extra:
		for v in changed_values.size():
			changed_values[v] = values[v] * extra['Pool']
	if "Echo" in extra:
		for v in changed_values.size():
			changed_values[v] = values[v] * extra['Echo']
	if "Split" in extra:
		for v in changed_values.size():
			changed_values[v] = values[v] * extra['Split']
	if "Multiply" in extra:
		for v in changed_values.size():
			changed_values[v] = values[v] * (1 + extra['Multiply']/100.0)

	for val in changed_tags.size():
		if changed_tags[val] in non_hit_tags or changed_tags[val] == "Duplicate" or changed_tags[val] == "Pierce" or changed_tags[val] == "Explosion" or changed_tags[val] == "Echo" or changed_tags[val] == "AreaPool" or changed_tags[val] == "SelfTarget":
			continue

		for e in range(enchants["Tags"].size()):
			if changed_tags[val] in enchants["Tags"]:
				extra.merge(enchants["Extra"][e], true)

		if "Lifesteal" in changed_tags[val]:
			unit.get_node('Control').on_action.emit(changed_values[changed_tags.find("Damage")] * (values[val]/100.0), area, unit, changed_tags[val], extra)
		elif "Shock" in changed_tags[val] or "Wind" in changed_tags[val]:
			unit.get_node('Control').on_action.emit(changed_values[val], area, unit, changed_tags[val], extra)
		elif "QuickAttack" in changed_tags[val]:
			var new_values = []
			var new_tags = []
			for i in range(values.size() - 2):
				new_values.append(values[i])
				new_tags.append(changed_tags[i])
			unit.get_node('Control').on_action.emit(changed_values[val], new_values, unit, changed_tags[val], new_tags)
		elif "Passive" in changed_tags[val]:
			unit.get_node('Control').on_action.emit(changed_values[val], area, unit, changed_tags[val], extra)
		elif "Damage" in changed_tags[val]:
			var new_damage = _apply_scaling(changed_values[val], ability_type)
			unit.get_node('Control').on_action.emit(new_damage, area, unit, changed_tags[val], extra)
			if unit.total_spell_vamp > 0:
				unit.get_node('Control').on_action.emit(new_damage * (unit.total_spell_vamp/100.0), unit, unit, "Heal", extra)
 
			_shake_camera()
		else:
			unit.get_node('Control').on_action.emit(changed_values[val], area, unit, changed_tags[val], extra)
	if GameManager.selected_character_name == "Warrior" and warrior_used_rage:
		added_percentage_damage -= mana_cost
		warrior_used_rage = false

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
