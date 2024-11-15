extends State
class_name ChasingState
var MAX_SPEED = 0
var colliding = false
var colliding_edge = false
var collision_direction = Vector2.ZERO
var colliding_obstacle_position = Vector2.ZERO
var colliding_obstacle_size = Vector2.ZERO
var avoidance_direction_type = ""
var closest_direction
var closest_avoidance_direction
var avoidance_force: float = 0.8
var avoidance_distance: float = 32.0
var ray_length: float = 1
const AVOIDANCE_RADIUS = 25.0
const ALIGNMENT_RADIUS = 10.0
const COHESION_RADIUS = 10.0
const AVOIDANCE_WEIGHT = 0.6
const ALIGNMENT_WEIGHT = 0.1
const COHESION_WEIGHT = 0.1
const PATH_TILE_UPDATE_INTERVAL = 0.2
const SPRITE_TILE_UPDATE_INTERVAL = 1.0

var velocity = Vector2()
var prev_positions = {}
var walking = false
var path = []
var current_path_index = -1
var player_tile = Vector2()
var timer = 3

func _action(_delta):
	_get_closest_target()
	_check_collision()
	MAX_SPEED = _unit.total_speed
	for i in range(ability_cooldowns.size()):
		if !_is_ability_on_cooldown((ability_cooldowns.size() - 1 )- i):
			return _change_state.call('casting')
		break
	if _unit.is_rooted or _unit.is_stunned or _unit.is_frozen or get_tree().get_first_node_in_group("players").in_stealth:
		return
	if _closest_distance > _unit.total_range + 10:
		_move_towards_target(_delta)
	else:
		_change_state.call('attacking')

func _flockBehaviour(_delta, target):
	var separation_vector = Vector2()
	var alignment_vector = Vector2()
	var cohesion_vector = Vector2()
	var total_neighbours = 0
	
	for unit in get_tree().get_nodes_in_group("enemies"):
		if unit != _unit:
			var distance = unit.global_position.distance_to(_unit.global_position)
			
			# Rule 1: Separation - steer to avoid collisions with other units
			if distance < AVOIDANCE_RADIUS:
				separation_vector += (_unit.global_position - unit.global_position).normalized() * AVOIDANCE_WEIGHT

			# Rule 2: Alignment - steer towards the average heading of other units
			if distance < ALIGNMENT_RADIUS:
				var unit_velocity = (_unit.global_position - prev_positions.get(unit, _unit.global_position)) / _delta
				alignment_vector -= unit_velocity.normalized() * ALIGNMENT_WEIGHT

			# Rule 3: Cohesion - steer to move towards the average position of other units
			if distance < COHESION_RADIUS:
				cohesion_vector += unit.global_position
				total_neighbours += 1

	if total_neighbours > 0:
		cohesion_vector /= total_neighbours
		cohesion_vector = (cohesion_vector - _unit.global_position).normalized() * COHESION_WEIGHT
	
	# Apply the rules to update the velocity
	velocity += (separation_vector + alignment_vector + cohesion_vector).normalized()
	# Rule 4: Attraction to the target (player)
	if velocity.length() > MAX_SPEED or velocity.length() < MAX_SPEED * 0.5:
		velocity = velocity.normalized()
	
	_linear_interpolate(velocity, Vector2.ZERO, 0.1)
	# Update the previous positions
	prev_positions[_unit] = _unit.global_position

func _move_towards_target(_delta):
	if current_path_index == -1 or current_path_index >= 1:
		if _update_path() == -1:
			print('No path found')
			return
	
	if _unit.total_speed <= 0:
		update_sprite_direction(path[current_path_index], "Walk", true)
	else:
		update_sprite_direction(path[current_path_index], "Walk", false)

	if colliding:
		if closest_avoidance_direction == null:
			colliding = false
			return
		update_sprite_direction(_get_closest_target().global_position, "Walk", false)
		_unit.global_position += closest_avoidance_direction * _unit.total_speed * _delta
		if avoidance_direction_type == "Horizontal":
			if _unit.global_position.distance_to(colliding_obstacle_position) > colliding_obstacle_size.size.x + 25:
				_update_path(colliding_obstacle_position)
				colliding = false
				_unit.is_colliding = false
		elif avoidance_direction_type == "Vertical":
			if _unit.global_position.distance_to(colliding_obstacle_position) > colliding_obstacle_size.size.y + 25:
				_update_path(colliding_obstacle_position)
				colliding = false
				_unit.is_colliding = false
	elif colliding_edge:
		_unit.global_position -= collision_direction * _unit.total_speed * _delta
		colliding_edge = false
		_unit.is_colliding = false
	else:
		_walk_from_to(path, _unit, _delta, PATH_TILE_UPDATE_INTERVAL, _get_closest_target())
	if _closest_distance > _unit.total_range:
		var separation_vector = Vector2()
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy != _unit:
				var enemy_position = enemy.global_position
				var separation = _unit.global_position.distance_to(enemy_position)
				if separation < 30 and _unit.total_speed > 0:
					separation_vector += (_unit.global_position - enemy_position).normalized() * (30 - separation)
		_unit.global_position += separation_vector * _delta * 2



func _walk_from_to(path, unit, delta, tile_update_interval, target):
	var target_tile = unit.obstacles_info._world_to_tilemap_position(target.global_position)
	var current_tile = unit.obstacles_info._world_to_tilemap_position(unit.global_position)
	var next_tile = path[current_path_index]
	var smooth_factor = 0.8
	var distance = unit.global_position.distance_to(next_tile)
	var direction = (next_tile - unit.global_position).normalized()
	var _velocity = direction * unit.total_speed * smooth_factor
	
	if distance >= 5:
		unit.global_position += _velocity * delta
	
	if distance < 5:
		current_path_index += 1
		if current_path_index > tile_update_interval:
			current_path_index = -1

func _set_player_tile_position(tile):
	player_tile = tile

func _check_if_player_moved():
	var player = _get_closest_target().global_position
	var new_player_tile = _unit.obstacles_info._world_to_tilemap_position(player)
	if player_tile != new_player_tile or current_path_index == -1:
		_set_player_tile_position(new_player_tile)
		_update_path()

func _update_path(excluded_tile = null):
	var new_path = _unit.obstacles_info._a_star(_unit.global_position, _get_closest_target().global_position, "AllMoves", _unit, excluded_tile)
	if new_path.size() == 0:
		return -1

	for i in range(new_path.size() - 1):
		var current_position = new_path[i]
		var next_position = new_path[i + 1]

		var direction = (next_position - current_position).normalized()

		var random_offset = direction * randf_range(1, 100)
		new_path[i] += random_offset
	path = new_path
	current_path_index = 0

func _linear_interpolate(start, end, weight):
		return start + (end - start) * weight

func _check_collision():
	var overlapping = _unit.get_overlapping_areas()
	
	for area in overlapping:
		if area.is_in_group('obstacles') and !colliding and area.get_meta('Walkable'):
			var collision_point_1 = area.get_node("CollisionShape2D").global_position
			var collision_point_2 = null
			if area.has_node("CollisionShape2D2"):
				collision_point_2 = area.get_node("CollisionShape2D2").global_position
			var collision_point
			if collision_point_2 != null:
				if collision_point_1.distance_to(_unit.global_position) < collision_point_2.distance_to(_unit.global_position):
					collision_point = collision_point_1
				else:
					collision_point = collision_point_2
			else:
				collision_point = collision_point_1
			collision_direction = (collision_point - _unit.global_position).normalized()
			colliding_obstacle_position = area.get_node("CollisionShape2D").global_position
			colliding_obstacle_size = area.get_node("CollisionShape2D").get_shape().get_rect()
			var direction_to_target = (_get_closest_target().global_position - _unit.global_position).normalized()
			var avoidance_direction = Vector2.ZERO
			var movement_threshold = 0
			var possible_avoidance_directions = []

			if abs(collision_direction.x) > abs(collision_direction.y):
				# Horizontal collision (from left or right)
				if abs(collision_direction.x) > movement_threshold:
					possible_avoidance_directions.append(Vector2(0, -1))  # Move right
					possible_avoidance_directions.append(Vector2(0, 1))  # Move left
					avoidance_direction_type = "Horizontal"
			else:
				# Vertical collision (from above or below)
				if abs(collision_direction.y) > movement_threshold:
					possible_avoidance_directions.append(Vector2(-1, 0))  # Move down
					possible_avoidance_directions.append(Vector2(1, 0))  # Move up
					avoidance_direction_type = "Vertical"

			var closest_angle_difference = 360

			for avoidance in possible_avoidance_directions:
				var angle_differences = abs(direction_to_target.angle_to(avoidance))
				if angle_differences < closest_angle_difference:
					closest_angle_difference = angle_differences
					closest_avoidance_direction = avoidance
			colliding = true
			_unit.is_colliding = true

		if area.is_in_group('obstacles') and !area.get_meta('Walkable'):
			collision_direction = (area.global_position - _unit.global_position).normalized()
			_unit.is_colliding = true
			colliding_edge = true
