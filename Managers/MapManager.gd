# FILEPATH: /C:/Users/Anton/Documents/Godot/Managers/MapManager.gd

extends Node

# The path to the town file.
@export var town_file : String

# The PackedScene for Arena 1. Will be one scene for all arenas in the future.
@export var arena_1_scene : PackedScene

# The PackedScene for Arena 2.
@export var arena_2_scene : PackedScene

@export var arena_3_scene : PackedScene

@export var town_scene : PackedScene

# The data of the tilemap.
var tilemap_data : Array = []

# The width of each tile in the tilemap.
var tilemap_tile_width : float = 0

# The height of each tile in the tilemap.
var tilemap_tile_height : float = 0

# The width of the tilemap.
var tilemap_width : int = 0

# The height of the tilemap.
var tilemap_height : int = 0

var disable_minimap = false

var minimap_tile_height : float = 0

var minimap_tile_width : float = 0

var minimap_total_width : float = 0

var minimap_total_height : float = 0

var minimap_scale

var minimap_position

var minimap_max_size

var minimap_min_size

var minimap_tilemap_width

var minimap_tilemap_height

var minimap_offset
# The positions of the tiles in the tilemap.
var tile_positions : Array = []

var minimap_positions : Array = []

# The array of walkable tiles.
var walkable_tiles : Array = []

# The wall tile.
var wall_tile

# The position of the teleporter.
var teleporter_position

# The spawn positions.
var spawn_position = []

# The special positions.
var special_positions = []

# The spawn position of boss.
var boss_spawn_position

# The array of units.
var units = []

# The array of creatures.
var creatures = []

var alive_creatures = 10

# A cache for storing the neighbors of each tile.
var cached_neighbors = {}

# The cumulative position.
var cumulative_position = Vector2.ZERO

var minimap_cumulative_position = Vector2.ZERO

# A flag indicating if the tile is walkable.
var walkable = false

# The array of players.
var players = []

# A flag indicating if the map is loaded.
var map_loaded

# Signal emitted when the map is changing.
signal changing_map

signal start_boss_cinematic(camera, target, duration, _name)

signal used_creatures(number, arr)



var current_path_index = 1

var temp_path = []

var pathfinding_timer = 0.0

var pathfinding_interval = 0.5

@export var pathfinding_debug = false

@export var spawn_effects : PackedScene
var spawn_effect

var grid_size

@export var im : Node

var sub_wave = 1

var paused_semaphore = Semaphore.new()


#----------------------#
# Main functions
#----------------------#

func _initialize():
	used_creatures.connect(get_parent().get_node('WaveManager')._on_map_manager_used_creatures)
	used_creatures.connect(get_parent().get_node('CombatManager')._update_sub_wave)
	spawn_effect = spawn_effects.instantiate()
	add_child(spawn_effect)
	spawn_effect.name = 'Spawn_effect'


#Start a wave, and cache the walkable neighboars for AI pathfinding.
func _start(file, tiles):
	for child in im.get_children():
		if child.name == 'Items':
			continue
		child.queue_free()
	for a in get_tree().get_root().get_node('Main').get_node('Objects').get_children():
		a.queue_free()
	_change_map(file, tiles)
	cached_neighbors.clear()
	_cache_neighbors()

# Change map to layout (map_path), and using specific tileset (tiles). Also clears priot tilemap/interactable objects on that tilemap.
func _change_map(map_path, tiles):
	changing_map.emit()
	spawn_position.clear()
	special_positions.clear()
	Utility.get_node('Interactable').interactable_objects.clear()
	Utility.get_node('Interactable').interactable_objects_hold.clear()
	Utility.get_node('Interactable').special_objects.clear()
	for i in get_tree().get_nodes_in_group('projectiles'):
		i.queue_free()
	for i in get_tree().get_nodes_in_group('obstacles'):
		i.queue_free()
	for child in get_children():
		if child.name == "Spawn_effect":
			continue
		child.queue_free()
	_loadTileMap(map_path, tiles)
	_initialize_tile_data()
	if units.size() > 0:
		units[0].global_position = teleporter_position
		units[0].get_node('Control').movement_target = Vector2.ZERO
		units[0].get_node('Control').attack_target = null
	
	grid_size = (tile_positions.size() * tile_positions[0].size()) 
	
func _increment_string(original_str: String, value_to_add: int) -> String:
	var parts = original_str.split("_")
	
	var prefix = parts[0]
	var number = parts[1].to_int()
	
	number += value_to_add
	var new_str = prefix + "_" + str(number)
	return new_str

func _get_special_positions():
	return special_positions

# Instantiate the tile scene
func _create_tile(scene, debug_color = Color.GREEN, debug = false):
	var instance = scene.duplicate()
	if instance.has_meta('Interactable'):
		if instance.get_meta('Interactable'):
			Utility.get_node('Interactable').interactable_objects.append(instance)
	if instance.has_meta('Special'):
		if instance.get_meta('Special'):
			Utility.get_node('Interactable').special_objects.append(instance)
			special_positions.append(cumulative_position + Vector2(tilemap_tile_width, 0))
	var sprite = instance.get_node("Sprite2D").texture
	if debug:
		instance.modulate = debug_color
	tilemap_tile_width = sprite.get_width() * instance.scale.x
	tilemap_tile_height = sprite.get_height() * instance.scale.y
	instance.global_position = cumulative_position + Vector2(tilemap_tile_width, 0)
	cumulative_position.x += tilemap_tile_width 
	walkable = instance.get_meta('Walkable')
	add_child(instance)

	if disable_minimap:
		return instance.global_position

	var minimap_sprite = instance.duplicate()
	minimap_sprite.modulate = Color(0.5, 0.5, 0.5, 0.7)
	minimap_sprite.set_script(null)
	minimap_sprite.scale = Vector2(minimap_scale, minimap_scale)
	players[0].get_node('InventoryManager').get_node('CanvasLayer').get_node('Minimap').add_child(minimap_sprite)
	minimap_tile_width = minimap_sprite.get_node("Sprite2D").texture.get_width() * minimap_scale
	minimap_tile_height = minimap_sprite.get_node("Sprite2D").texture.get_height() * minimap_scale
	minimap_sprite.global_position = minimap_cumulative_position + Vector2(minimap_tile_width, 0)
	minimap_cumulative_position.x += minimap_tile_width
	minimap_total_width += minimap_tile_width

	return instance.global_position
# Load the tilemap from layout (file) with specific tileset(tiles). Creates two arrays, tile_positions for all center positions of the tiles
# and walkable_tiles to represent which tiles are walkable. Populates with _create_tile - teleporter and spawn always needs to have index 2
# and 3 respectfully to save their position for use.
func _loadTileMap(file, tiles):
	var f = FileAccess.open(file, FileAccess.READ)
	var debug_walkable = Color.GREEN
	if f:
		var content = f.get_as_text()
		f.close()
		tilemap_data = content.split("\n")
		tilemap_height = tilemap_data.size()
		tilemap_width = tilemap_data[0].length()
		cumulative_position = Vector2(0, 1000)
		
		minimap_max_size = Vector2(500, 500)

		var scale_x = minimap_max_size.x / (tilemap_width * tilemap_tile_width)
		var scale_y = minimap_max_size.y / (tilemap_height * tilemap_tile_height)
		minimap_scale = min(scale_x, scale_y)  # Uniform scaling to fit within the rectangle

		minimap_tilemap_width = tilemap_width * tilemap_tile_width * minimap_scale
		minimap_tilemap_height = tilemap_height * tilemap_tile_height * minimap_scale
	
		minimap_position = get_viewport().get_visible_rect().size - minimap_max_size + Vector2(150, 150)
		minimap_cumulative_position = minimap_position
		players[0].get_node('InventoryManager').get_node('CanvasLayer').get_node('Minimap').is_enabled = false
		for i in players[0].get_node('InventoryManager').get_node('CanvasLayer').get_node('Minimap').get_children():
			i.queue_free()
		tile_positions = []
		walkable_tiles = []
		minimap_positions = []
		players[0].get_node('InventoryManager').get_node('CanvasLayer').get_node('Minimap').players_arr.clear()
		
		for y in range(tilemap_data.size()):
			var line = tilemap_data[y]
			var row = []
			var row2 = []
			var minimap_row = []
			var x = 0
			while x < line.length():
				var tile_value = ""
				while x < line.length() and line[x] != ",":
					tile_value += line[x]
					x += 1
				x += 1
				var tile_int = int(tile_value)
				for tile in range(tiles.size()):
					if tile_int == tile:
						if tiles[tile].get_meta('Walkable'):
							row2.append(true)
							debug_walkable = Color.GREEN
						else:
							debug_walkable = Color.RED
							row2.append(false)
						if tiles[tile].has_meta('Player_Spawn'):
							teleporter_position = _create_tile(tiles[tile])
							row.append(teleporter_position)
						elif tiles[tile].has_meta('Mob_Spawn'):
							spawn_position.append(_create_tile(tiles[tile]))
							row.append(spawn_position[spawn_position.size()-1])
						elif tiles[tile].has_meta('Boss_Spawn'):
							boss_spawn_position = _create_tile(tiles[tile])
							row.append(boss_spawn_position)
						else:
							_create_tile(tiles[tile], debug_walkable, pathfinding_debug)
							row.append(cumulative_position)
						minimap_row.append(minimap_cumulative_position)
			cumulative_position.x = 0  # Reset X for the next row
			cumulative_position.y += tilemap_tile_height
			minimap_cumulative_position.x = minimap_position.x
			minimap_cumulative_position.y += minimap_tile_height
			tile_positions.append(row)
			minimap_positions.append(minimap_row)
			walkable_tiles.append(row2)
			for i in range(tiles.size()):
				tiles[i].queue_free()

		players[0].get_node('InventoryManager').get_node('CanvasLayer').get_node('Minimap').is_enabled = true
	else:
		print("Error: Unable to open the file.")

#----------------------#
# Tilemap Helper functions
#----------------------#

func _get_tilemap_index(position):
	for y in range(tile_positions.size()):
		for x in range(tile_positions[y].size()):
			if tile_positions[y][x] == position:
				return Vector2(x, y)
	return Vector2(-1, -1)

func _get_minimap_position_from_index(index):
	return minimap_positions[index.y][index.x]

func _check_tile_meta(meta, instance):
	if instance.has_meta(meta):
		if instance.get_meta(meta):
			return true
	return false

class Tile_Data:
	var position : Vector2
	var walkable : bool
	
	func _initialize(_position: Vector2, _walkable: bool):
		position = _position
		walkable = _walkable

var tile_data_dict : Dictionary = {}

func _initialize_tile_data():
	tile_data_dict.clear()
	for y in range(tile_positions.size()):
		for x in range(tile_positions[y].size()):
			var _position = tile_positions[y][x]
			var _walkable = walkable_tiles[y][x]
			var tile_data = Tile_Data.new()
			tile_data._initialize(_position, _walkable)
			tile_data_dict[_position] = tile_data

func _get_random_walkable_tile():
	var tiles = []
	for tile in tile_data_dict.values():
		if tile.walkable:
			tiles.append(tile.position)
	return tiles.pick_random()

func _get_random_spawn_position():
	return spawn_position[randi() % spawn_position.size()]

# Typical a-star  algorithm, where you can either chose to get the first move or all moves calculated to a goal.
func _a_star(startt, goalt, type, unit = null, excluded_tile = null):
	var open_set = []
	var closed_set = []
	var came_from = {}
	var start = _world_to_tilemap_position(startt)
	var goal = _world_to_tilemap_position(goalt)
	var excluded = _world_to_tilemap_position(excluded_tile)
	var current = start

	if !_is_tile_walkable(goal):
		goal = _find_last_player_tile_position()

	open_set.append(start)
	while open_set.size() > 0:
		current = _get_lowest_f_score(open_set, start, goal)
		if current == goal:  # Use squared distance to avoid square root
			if type == 'AllMoves':
				return _reconstruct_path(came_from, start, goal, true)
			elif type == 'FirstMove':
				return _reconstruct_path(came_from, start, goal, false)[1]
		open_set.erase(current)
		closed_set.append(current)

		for neighbor in _get_neighbors(current):
			if closed_set.find(neighbor) != -1 or !_is_tile_walkable(neighbor, unit):
				continue
			
			if excluded != null and neighbor == excluded:
				continue

			var tentative_g_score = _calculate_g_score(current, start) + current.distance_squared_to(neighbor)
			if open_set.find(neighbor) == -1 or tentative_g_score < _calculate_g_score(neighbor, start):
				came_from[neighbor] = current
				if open_set.find(neighbor) == -1:
					open_set.append(neighbor)
	current_path_index = 0
	return _reconstruct_path(came_from, start, current, true)

func _find_closest_walkable_neighbor(goal, unit):
	var neighbors = _calculate_neighbors(goal)
	var distance = INF
	for neighbor in neighbors:
		if _is_tile_walkable(neighbor) and neighbor.distance_to(unit.global_position) < distance:
			distance = neighbor.distance_to(unit.global_position)
			goal = neighbor
	return goal

func _find_last_player_tile_position():
	var control_node = players[0].get_node("Control")
	var history_size = control_node.tile_history.size()

	for i in range(history_size - 1, -1, -1):
		var tile_position = control_node.tile_history[i]
		if _is_tile_walkable(tile_position):
			return tile_position
	return Vector2.ZERO


func _walk_from_to(path, unit, delta, goal_index, _target):
	var separation_vector = Vector2.ZERO
	if current_path_index >= path.size() - 1:
		current_path_index = -1
		return current_path_index
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy != unit:
			var enemy_position = enemy.global_position
			var separation = unit.global_position.distance_to(enemy_position)
			if separation < 22:
				separation_vector += (unit.global_position - enemy_position).normalized() * (52 - separation)
	for summon in get_tree().get_nodes_in_group('player_summon'):
		if summon != unit:
			var summon_position = summon.global_position
			var separation = unit.global_position.distance_to(summon_position)
			if separation < 22:
				separation_vector += (unit.global_position - summon_position).normalized() * (52 - separation)

	var new_path = path
	var current_position = unit.global_position
	var target_position = new_path[current_path_index]
	var direction = (target_position - current_position).normalized()
	var distance = current_position.distance_to(target_position)
	
	if separation_vector.length() > 0:
		direction = (direction + separation_vector.normalized()).normalized()

	var move_distance = min(distance, delta * unit.total_speed)
	unit.global_position += direction * move_distance

	if distance <= 2:
		current_path_index += 1
		if current_path_index >= new_path.size() - 1:
			current_path_index = -1

	temp_path = new_path
	return current_path_index


func smooth_path(path, unit):
	var smoothed_path = [path[0]]
	var current_index = 0
	while current_index < path.size() - 1:
		var next_index = current_index + 1
		var line_clear = true
		var start = _world_to_tilemap_position(path[current_index])
		var end = _world_to_tilemap_position(path[next_index])
		var dir = (end - start).normalized()
		var distance = start.distance_to(end)
		var steps = distance / 128  # Assuming TILE_SIZE is the size of your tiles
		for i in range(steps):
			var pos = start + dir * i * 128
			var tile_position = _world_to_tilemap_position(pos)
			if !_is_tile_walkable(tile_position):
				line_clear = false
				break
		if line_clear:
			# Line segment is clear, remove the waypoint
			smoothed_path.append(path[next_index])
			current_index = next_index
		else:
			# Line segment is blocked, keep the waypoint
			smoothed_path.append(path[next_index])
			current_index = next_index
	return smoothed_path


# Finds the closest tile to arbritary world position.	
func _world_to_tilemap_position(_world_position):
	if _world_position == null:
		return

	var distance = INF
	var current_tile
	for tile in tile_data_dict.values():
		var dist = _world_position.distance_squared_to(tile.position)
		if dist < distance and tile.walkable:
			distance = dist
			current_tile = tile.position
	return current_tile

func _world_to_tilemap_position_all(_world_position):
	if _world_position == null:
		return

	var distance = INF
	var current_tile
	for tile in tile_data_dict.values():
		var dist = _world_position.distance_squared_to(tile.position)
		if dist < distance:
			distance = dist
			current_tile = tile.position
	return current_tile
	
# Finds a walkable tile away from the given position.
func _find_walkable_tile_away_from(_position):
	var max_attempts = 100
	var min_distance_squared = (128 * 4) ** 2
	var y = tile_positions.size() - 1
	var x = tile_positions[0].size()
	
	while max_attempts > 0:
		var random_x = randi() % x
		var random_y = randi() % y
		
		var random_tile = tile_positions[random_y][random_x]
		
		if _is_tile_walkable(random_tile):
			var distance_squared = _position.distance_squared_to(random_tile)
			if distance_squared >= min_distance_squared:
				return random_tile
		
		max_attempts -= 1
	return Vector2.ZERO

func _find_walkable_tile_towards(_position):
	var max_attempts = 100
	var min_distance_squared = (128 * 4) ** 2
	var y = tile_positions.size() - 1
	var x = tile_positions[0].size()
	
	while max_attempts > 0:
		var random_x = randi() % x
		var random_y = randi() % y
		
		var random_tile = tile_positions[random_y][random_x]
		
		if _is_tile_walkable(random_tile):
			var distance_squared = _position.distance_squared_to(random_tile)
			if distance_squared <= min_distance_squared:
				return random_tile
		
		max_attempts -= 1
	return Vector2.ZERO
	
func _find_random_walkable_tile():
	var max_attempts = 100
	var y = tile_positions.size() - 1
	var x = tile_positions[0].size()
	
	while max_attempts > 0:
		var random_x = randi() % x
		var random_y = randi() % y
		
		var random_tile = tile_positions[random_y][random_x]
		
		if _is_tile_walkable(random_tile):
			return random_tile
		
		max_attempts -= 1
	return Vector2.ZERO

# Check if a tile at the given position is walkable.
# Returns true if the tile is walkable, false otherwise.
func _is_tile_walkable(tile_position, unit = null) -> bool:
	var tile_size = Vector2(128, 128)
	var index = _find_index_in_2d_array(tile_position)	
	return walkable_tiles[index.y][index.x]
	
# Cache the neighbors for each tile position.
func _cache_neighbors():
	var pos
	for tile in tile_data_dict.values():
		pos = tile.position
		var neighbors = _calculate_neighbors(pos)
		cached_neighbors[pos] = neighbors


# Calculates the neighbors of a given position in the tile map.
func _calculate_neighbors(pos: Vector2) -> Array:
	var neighbors = []
	var index = _find_index_in_2d_array(pos)

	var offsets = [
		Vector2(0, -1),  # Up
		Vector2(0, 1),   # Down
		Vector2(-1, 0),  # Left
		Vector2(1, 0)    # Right
	]
	
	for offset in offsets:
		var neighbor_pos = index + offset
		if _is_valid_neighbor(neighbor_pos, pos):
			neighbors.append(tile_positions[neighbor_pos.y][neighbor_pos.x])

	return neighbors

# Checks if a neighbor position is valid within the map boundaries.
# Returns true if the neighbor position is valid, false otherwise.
func _is_valid_neighbor(neighbor_pos: Vector2, _pos_index: Vector2) -> bool:
	var width = tile_positions[0].size()
	var height = tile_positions.size() - 1

	if neighbor_pos.x >= 0 and neighbor_pos.x < width and neighbor_pos.y >= 0 and neighbor_pos.y < height:
		return true
	return false

func _is_diagonal_neighbor(neighbor_pos: Vector2, _pos_index: Vector2) -> bool:
	if neighbor_pos.x != _pos_index.x and neighbor_pos.y != _pos_index.y:
		return true
	return false

# Retrieves the neighbors of a given position.
# Returns an array of neighboring positions.
func _get_neighbors(pos: Vector2) -> Array:
	return cached_neighbors[pos]

# Finds the index of a value in a 2D array.
# Returns the index as a Vector2 if found, (-1,-1) otherwise.
func _find_index_in_2d_array(value_to_find: Vector2) -> Vector2:
	for y in range(tile_positions.size()):
		for x in range(tile_positions[y].size()):
			if tile_positions[y][x] == value_to_find:
				return Vector2(x, y)
	return Vector2(-1,-1)

# Returns the position with the lowest f score from the open list.
# The f score is calculated based on the given start position and end position.
func _get_lowest_f_score(open_list, start_pos, end_pos) -> Vector2:
	var lowest_f = INF
	var lowest_pos = Vector2.ZERO
	
	for pos in open_list:
		var f_score = _calculate_f_score(pos, start_pos, end_pos)
		if f_score < lowest_f:
			lowest_f = f_score
			lowest_pos = pos
	return lowest_pos

# Calculates the f score for the given position.
# The f score is the sum of the g score and h score.
func _calculate_f_score(pos: Vector2, start_pos: Vector2, end_pos: Vector2) -> float:
	var g_score = _calculate_g_score(pos, start_pos)
	var h_score = _calculate_h_score(pos, end_pos)
	return g_score + h_score

# Calculates the g score for the given position.
# The g score is the squared distance between the position and the start position.
func _calculate_g_score(pos: Vector2, start_pos: Vector2) -> float:
	return pos.distance_squared_to(start_pos)

# Calculates the h score for the given position.
# The h score is the squared distance between the position and the end position.
func _calculate_h_score(pos: Vector2, end_pos: Vector2) -> float:
	return pos.distance_squared_to(end_pos)

# Reconstructs the path from the given start position to the given goal position.
# The path is reconstructed using the came_from dictionary.
func _reconstruct_path(came_from, start, goal, all) -> Array:
	var path = [goal]
	var current = goal
	
	while current.distance_to(start) > 10:
		path.append(current)
		if current in came_from:
			current = came_from[current]
	
	path.reverse()
	return path

#----------------------#
# Signals
#----------------------#

func _on_character_selected(unit):
	players.append(unit)
	players[0].obstacles_info = self

# map is string name of the map. Should be same as layout. Needs to change to use map variable.
func _get_tiles_for_map(map):
	var tiles
	disable_minimap = false
	if map == 1:
		tiles = arena_1_scene.instantiate()
	elif map == 2:
		tiles = arena_2_scene.instantiate()
	elif map == 0:
		tiles = town_scene.instantiate()
		disable_minimap = true
	elif map == 3:
		tiles = arena_3_scene.instantiate()
	var children = tiles.get_children()
	tiles.queue_free()
	return children

func _on_next_shop(_time):
	_start(town_file, _get_tiles_for_map(0))


func _on_next_choice():
	_start(town_file, _get_tiles_for_map(0))


func _on_get_units(unit):
	creatures = unit

func _on_wave_manager_start_wave(_value, wave):
	_start('res://Maps/Tiles/Arena_' + str(wave) + '/Layouts/0.txt', _get_tiles_for_map(wave))
	sub_wave = 1
	await get_tree().create_timer(4.0).timeout
	_spawn_and_attach()

func _start_boss_encounter(_value, index):
	for child in im.get_children():
		if child.name == 'Items':
			continue
		child.queue_free()
	_start('res://Maps/Tiles/Arena_' + str(index) + '/arena_boss_'+str(index)+'.txt', _get_tiles_for_map(index))
	var nm = 0
	var boss
	for c in creatures:
		if c.is_in_group('boss'):
			c.global_position = boss_spawn_position
			boss = c
		else:
			c.global_position = spawn_position[nm]
			nm += 1
		c.obstacles_info = self
		c.drop_info = im
	players[0].get_node('Camera').get_child(0).global_position = teleporter_position
	start_boss_cinematic.emit(players[0].get_node('Camera').get_child(0), boss.global_position, 5, boss.u_name)

func _start_sub_wave(subwave, wave):
	for child in im.get_children():
		if child.name == 'Items':
			continue
		child.queue_free()
	_start('res://Maps/Tiles/Arena_' + str(wave) + '/Layouts/' + str(subwave) + '.txt', _get_tiles_for_map(wave))
	sub_wave = subwave + 1
	await get_tree().create_timer(4.0).timeout
	_spawn_and_attach()

func _respawn_creatures(_value):
	_spawn_and_attach()

func _spawn_effects(_position):
	var sp = spawn_effect.duplicate()
	sp.global_position = _position
	add_child(sp)
	sp.get_child(0).emitting = true

func _spawn_and_attach():
	players[0].in_combat = true
	var nm = 0
	var arr = []
	var random_creatures = []
	var creature_positions = []
	var random_increase = int((int(grid_size/30) + 3) * creatures[0].increased_amount)
	var spawn_time = 1.5
	
	for i in range(random_increase):
		random_creatures = await _calculate_creature(random_increase)
	for c in random_creatures:
		var d = c.duplicate()

		while players[0].paused:
			await get_tree().create_timer(0.1).timeout

		creature_positions.append(_get_random_walkable_tile())
		d.global_position = creature_positions[nm]
		d.obstacles_info = self
		d.drop_info = im
		arr.append(d)
		add_child(d)
		nm += 1
		arr.shuffle()
	used_creatures.emit(nm, arr)
	for a in range(arr.size()):

		while players[0].paused:
			await get_tree().create_timer(0.1).timeout

		if a > 0 and a % 10 == 0:
			await get_tree().create_timer(alive_creatures).timeout
			alive_creatures += 10
		arr[a].paused = false
		arr[a].visible = true
		arr[a].add_to_group('enemies', true)
		_spawn_effects(arr[a].global_position)
		await get_tree().create_timer(spawn_time).timeout

func _on_creature_dead():
	alive_creatures -= 1

func _get_creatures_for_sub_wave(wave, array):
	array.append(creatures[randi() % wave + 1])

func _on_round_manager_start_singleplayer():
	_start(town_file, _get_tiles_for_map(0))
	units.append(players[0])
	players[0].global_position = teleporter_position

func _calculate_creature(size):
	var arr = []
	var s = sub_wave
	if s > creatures.size():
		s = creatures.size()
	for i in range(0, s):
		var percentage_of_total = int(size / (i + 1))
		var num_to_spawn = percentage_of_total

		if i == s - 1 and i != 0:
			num_to_spawn = min(num_to_spawn, 2)
		for j in range(0, num_to_spawn):
			arr.append(creatures[i])
	return arr

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print('exiting..')
		spawn_position.clear()
		special_positions.clear()
		Utility.get_node('Interactable').interactable_objects.clear()
		Utility.get_node('Interactable').interactable_objects_hold.clear()
		Utility.get_node('Interactable').special_objects.clear()
		for i in get_tree().get_nodes_in_group('projectiles'):
			i.queue_free()

		for i in get_tree().get_nodes_in_group('obstacles'):
			i.queue_free()
		
		for i in get_tree().get_nodes_in_group('enemies'):
			i.queue_free()

		for child in get_children():
			child.queue_free()

		# Fix this somewhen
		var orhpans = get_tree().get_nodes_in_group("all_nodes")
		print_orphan_nodes()
		for orphan in orhpans:
			print(orphan.name)
			orphan.queue_free()
		get_tree().quit()
