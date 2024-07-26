extends Node
class_name Task

enum{
	FRESH,
	RUNNING,
	FAILED,
	SUCCEEDED,
	CANCELLED
}

var control = null
var tree = null
var guard = null
var status = null
var unit = null
var target = null
var velocity = Vector2()
var walking = false
var colliding = false
var collision_direction = Vector2()
var current_path_index = -1
var path = null
var ability_cooldowns = []
var timers = []
var current_index = 0
var cast_bar = null
var cast_timer = 0
var cast_duration = 0
var attack_timer = 0
var textures : Dictionary = {
}
var animation
var current_sprite_direction

func update_sprite_direction(target_position, type, _idle):
	var direction_vector = target_position - unit.global_position
	# Determine the cardinal direction based on the direction vector'
	if abs(direction_vector.x) > abs(direction_vector.y):
		if direction_vector.x > 0:
			current_sprite_direction = type + " East"
			animation.play(current_sprite_direction)
		else:
			current_sprite_direction = type + " West"
			animation.play(current_sprite_direction)
	else:
		if direction_vector.y > 0:
			current_sprite_direction = type + " South"
			animation.play(current_sprite_direction)
		else:
			current_sprite_direction = type + " North"
			animation.play(current_sprite_direction)	

func set_texture_direction(texture):
	self.texture = texture

func _check_collision():
	var overlapping = unit.get_overlapping_areas()
	colliding = false
	
	for area in overlapping:
		if area.is_in_group('obstacles'):
			var collision_point = area.get_node("CollisionShape2D").global_position
			collision_direction = (collision_point - unit.global_position).normalized()
			colliding = true

func _move_random_target(_target_position, _delta, summon = false):
	if unit.global_position.distance_to(_target_position) > 10 or path == null:
		_update_path()
	var _target
	if summon:
		_target = _get_closest_enemy()
	else:
		_target = _get_closest_target()	
	_check_collision()
	if colliding:
		unit.global_position -= collision_direction * unit.total_speed * _delta
	else:
		current_path_index = unit.obstacles_info._walk_from_to(path, unit, _delta, 1, _target)
	if unit.total_speed <= 0 or unit.is_rooted:
		update_sprite_direction(_target.global_position, "Walk", true)
	else:
		update_sprite_direction(_target.global_position, "Walk", false)
	
func _update_path(summon = false):
	var new_path
	if summon:
		new_path = unit.obstacles_info._a_star(unit.global_position, _get_closest_enemy().global_position, "AllMoves")
	else:
		new_path = unit.obstacles_info._a_star(unit.global_position, _get_closest_target().global_position, "AllMoves")
	if new_path.size() > 0:
		path = new_path
		current_path_index = 0
		return
	current_path_index = -1
			
func _set_ability_on_cooldown(index):
	timers[index] = ability_cooldowns[index]
	
func _change_ability_cooldown(index, cd):
	if ability_cooldowns[index]:
		ability_cooldowns[index] = cd

func _linear_interpolate(start, end, weight):
		return start + (end - start) * weight

func _running():
	status = RUNNING
	if control != null:
		control._child_running()

func _success():
	status = SUCCEEDED
	if control != null:
		control._child_success()

func _fail():
	status = FAILED
	if control != null:
		control._child_fail()
		
func _cancel():
	if status == RUNNING:
		status = CANCELLED
		# Cancel child tasks
		for child in get_children():
			child._cancel()

func _run(_delta):
	pass
	
func _child_success():
	pass
	
func _child_fail():
	pass
	
func _child_running():
	pass
	
func _start():
	status = FRESH
	for child in get_children():
		child.control = self
		child.tree = self.tree
		child.unit = self.unit
		child.timers = self.timers
		child.animation = self.animation
		child.ability_cooldowns = self.ability_cooldowns
		child.cast_bar = self.cast_bar
		child.current_index = self.current_index
		child.target = _get_closest_enemy()
		child.attack_timer = unit.total_windup_time
		child._start()

func _reset():
	_cancel()
	status = FRESH

func _get_closest_target():
	var distance_to_target = 99999999
	if get_tree().get_nodes_in_group('players'):
		for child in get_tree().get_nodes_in_group('players'):
			var distance = unit.global_position.distance_to(child.global_position)
			
			if distance < distance_to_target:
				distance_to_target = distance
				return child

func _get_closest_enemy():
	var distance_to_target = 99999999
	if get_tree().get_nodes_in_group('enemies'):
		for child in get_tree().get_nodes_in_group('enemies'):
			var distance = unit.global_position.distance_to(child.global_position)
			
			if distance < distance_to_target:
				distance_to_target = distance
				return child
	return null

