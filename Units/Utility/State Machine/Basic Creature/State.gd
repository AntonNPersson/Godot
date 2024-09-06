extends Node
class_name State
var _change_state
var _unit
var _closest_distance : float = 9999
var tile_size = Vector2(128, 128)
var open_set = []
var closed_set = []
var tilemap_data
var ability_cooldowns = []
var ability_cast_duration = []
var ranges = []
var timers = []
var current_index = 0
var animation
var current_sprite_direction
var update_timer
var current_frame = 0
var current_progress = 0.0

var cast_bar = null
var cast_timer = 0.0
var is_casting = false

func _setup(change_state, unit):
	self._change_state = change_state
	self._unit = unit
	self.tilemap_data = _unit.obstacles_info
	animation = _unit.get_node('AnimatedSprite2D')
	cast_bar = _unit.get_node('UI/cast_bar')
	for ability_ in range(_unit.abilities.size()):
		var pre = _unit.abilities[ability_].instantiate()
		ability_cooldowns.append(pre.cooldown)
		ability_cast_duration.append(pre.cast_duration)
		var timer = pre.cooldown
		timers.append(timer)
		ranges.append(pre._range)
		print(pre.name)
		pre.queue_free()

func _update(delta):
	for i in range(timers.size()):
		timers[i] -= delta
func update_sprite_direction(target_position, type, idle):
	var direction_vector = target_position - _unit.global_position
	current_frame = animation.get_frame()
	current_progress = animation.get_frame_progress()

	if type == "Walk":
		animation.speed_scale = 1
	# Determine the cardinal direction based on the direction vector'
	if abs(direction_vector.x) > abs(direction_vector.y):
		if direction_vector.x > 0:
			current_sprite_direction = type + " East"
			animation.play(current_sprite_direction)
			animation.set_frame_and_progress(current_frame, current_progress)
		else:
			current_sprite_direction = type + " West"
			animation.play(current_sprite_direction)
			animation.set_frame_and_progress(current_frame, current_progress)
	else:
		if direction_vector.y > 0:
			current_sprite_direction = type + " South"
			animation.play(current_sprite_direction)
			animation.set_frame_and_progress(current_frame, current_progress)
		else:
			current_sprite_direction = type + " North"
			animation.play(current_sprite_direction)
			animation.set_frame_and_progress(current_frame, current_progress)
	
	if idle:
		animation.play(current_sprite_direction, 0)
	
	if type == "Attack":
		var base_frame_time = 1.0/2.0
		var animation_fps = base_frame_time * animation.sprite_frames.get_frame_count(current_sprite_direction)
		var speed_scale = animation_fps / _unit.total_windup_time
		_unit.get_node('AnimatedSprite2D').speed_scale = speed_scale/2
		

func _action(_delta):
	pass

func _update_cast_timer(delta):
	cast_timer += delta
	if ability_cast_duration.size() > 0:
		cast_bar.value = _calculate_cast_percentage(ability_cast_duration[current_index])
	if cast_bar.value >= 100:
		cast_bar.visible = false
		is_casting = false

func _interrupt_cast_timer():
	cast_timer = 0
	cast_bar.value = 0
	
func _set_ability_on_cooldown(index):
	timers[index] = ability_cooldowns[index]

func _start_cast_bar(duration):
	cast_bar.visible = true
	cast_bar.value = 0
	cast_timer = duration
	
func _calculate_cast_percentage(duration):
	var perc = (cast_timer/duration) * 100
	return perc

func _is_ability_on_cooldown(index):
	if timers[index] <= 0 and _unit.global_position.distance_to(_get_closest_target().global_position) < ranges[index] and !is_casting:
		current_index = index
		print(current_index)
		return false
	else:
		return true

func _get_closest_target():
	var distance_to_target = 99999999
	if get_tree().get_nodes_in_group('players'):
		for child in get_tree().get_nodes_in_group('players'):
			var distance = _unit.global_position.distance_to(child.global_position)
			
			if distance < distance_to_target:
				distance_to_target = distance
				_closest_distance = distance_to_target
				return child
	return _unit
