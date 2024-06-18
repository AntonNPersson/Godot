extends Node2D
var GRID_WIDTH = 8
var GRID_HEIGHT = 8

var tiles = []
var obstacles = []
var grid = []
var grid_array = []
var selected_tile = null
var selected_obstacle = null
var selected_index = -1
var map_count = 0

const TILE_SIZE = 128
const LINE_WIDTH = 2

var block_click = false
var holding_tile = false
var creature_spawn = false
var player_spawn = false
var drawing = false

@onready var node2d = Node2D.new()

func _ready():
	_update_grid()
	_add_obstacles_to_list()

func _process(delta):
	if holding_tile:
		_place_tile()

func _draw():
	if drawing:
		print("Drawing")
		for i in (get_node('tiles').get_children()):
			if i.get_meta('Mob_Spawn'):
				print("Drawing mob spawn")
				draw_circle(i.global_position, 24, Color(1, 0, 0, 0.5))
			if i.get_meta('Player_Spawn'):
				draw_circle(i.global_position, 24, Color(0, 1, 0, 0.5))

func _update_grid():
	grid.clear()
	grid_array.clear()
	for y in range(GRID_HEIGHT):
		var row = []
		var row_array = []
		for x in range(GRID_WIDTH):
			row.append(-1)
			var center = Vector2(x * TILE_SIZE + TILE_SIZE / 2, y * TILE_SIZE + TILE_SIZE / 2)
			row_array.append(center)
		grid.append(row)
		grid_array.append(row_array)

func _input(event):
	if block_click:
		return
	if tiles.size() == 0:
		print("No tiles loaded")
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_place_tile()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_remove_tile()
	elif event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			if event.pressed:
				selected_obstacle = null
				get_node('CanvasLayer/ItemList2').deselect_all()
				holding_tile = true
			else:
				holding_tile = false

func _add_obstacles_to_list():
	var itemlist = get_node('CanvasLayer/ItemList2')
	var dir = DirAccess.open("res://Tool/obstacles/")
	if not dir:
		print("Failed to open directory")
		return
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if file.ends_with(".png"):
			var tile = load("res://Tool/obstacles/" + file)
			itemlist.add_item(file, tile)
			obstacles.append(tile)


func _place_tile():
	get_node("CanvasLayer/CheckBox2").button_pressed = false
	get_node("CanvasLayer/CheckBox").button_pressed = false
	var mouse_pos = get_global_mouse_position()
	var grid_pos = _to_grid_position(mouse_pos)
	if grid_pos or grid_pos == Vector2(0,0):
		var tile_data = _get_tile_data(grid_pos.x, grid_pos.y)
		if tile_data != -1:
			return
		_set_tile_data(grid_pos.x, grid_pos.y, selected_index)
		var tile = tiles[selected_index].duplicate()
		tile.name = str(grid_pos.x) + "_" + str(grid_pos.y)
		tile.visible = true
		tile.position = grid_array[grid_pos.y][grid_pos.x]

		if creature_spawn:
			var if_exist = _check_if_tile_exist('Mob_Spawn', tile)
			if if_exist != false:
				_set_tile_data(grid_pos.x, grid_pos.y, if_exist)
				queue_redraw()
				return
				
			tile.set_meta('Mob_Spawn', true)
			print(tile.has_meta('Mob_Spawn'))
			tiles.append(tile)
			_set_tile_data(grid_pos.x, grid_pos.y, tiles.size() - 1)
			drawing = true
			queue_redraw()

		if player_spawn:
			var if_exist = _check_if_tile_exist('Player_Spawn', tile)
			if if_exist != false:
				_set_tile_data(grid_pos.x, grid_pos.y, if_exist)
				queue_redraw()
				return

			tile.set_meta('Player_Spawn', true)
			tiles.append(tile)
			_set_tile_data(grid_pos.x, grid_pos.y, tiles.size() - 1)
			drawing = true
			queue_redraw()
		get_node('tiles').add_child(tile)
		if selected_obstacle == null:
			return
		var sprite = Sprite2D.new()
		sprite.name = "Obstacle_Sprite"
		var new_tile = tiles[selected_index].duplicate()
		new_tile.name += "_obstacle"
		sprite.texture = selected_obstacle
		new_tile.add_child(sprite)
		new_tile.set_meta('Walkable', true)
		tiles.append(new_tile)
		get_node("CanvasLayer/ItemList").add_item(new_tile.name, selected_obstacle)
		get_node('CanvasLayer/ItemList').deselect_all()
		get_node('CanvasLayer/ItemList2').deselect_all()
		selected_obstacle = null
		_set_tile_data(grid_pos.x, grid_pos.y, tiles.size() - 1)
		print("Placed tile at", grid_pos, "with index", selected_index, "and tile", new_tile.name)

func _check_if_tile_exist(meta, tilee):
	for i in range(tiles.size()):
		var tile = tiles[i]
		if tile.get_node('Sprite2D').texture != tilee.get_node('Sprite2D').texture:
			return false
		if tile.has_meta(meta):
			return i
		return false

func _remove_tile():
	var mouse_pos = get_global_mouse_position()
	var grid_pos = _to_grid_position(mouse_pos)
	if grid_pos:
		var tile_data = _get_tile_data(grid_pos.x, grid_pos.y)
		if tile_data != -1:
			var tile_name = str(grid_pos.x) + "_" + str(grid_pos.y)
			var tile = get_node('tiles').get_node(tile_name)
			tile.queue_free()
			_set_tile_data(grid_pos.x, grid_pos.y, -1)
			print("Removed tile at", grid_pos)

func _save_grid_to_file(only_text = false):
	var file = FileAccess.open("res://Tool/Tilesets//"+ str(map_count) + ".txt", FileAccess.WRITE)
	if not file:
		print("Failed to open file")
		return
	
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			file.store_string(str(grid[y][x]))
			if x < GRID_WIDTH - 1:
				file.store_string(",")
		file.store_string("\n")

	if only_text:
		map_count += 1
		file.close()
		return
	node2d.name = "Arena_"
	for i in range(tiles.size()):
		var tile = tiles[i].duplicate()
		node2d.add_child(tile)
		tile.set_owner(node2d)
		for t in tile.get_children():
			if t.name == "Obstacle_Sprite":
				t.set_owner(node2d)

	
	var packed_scene = PackedScene.new()
	packed_scene.pack(node2d)

	var error = ResourceSaver.save(packed_scene, "res://Tool/Tilesets/arena_.tscn")
	if error != OK:
		print("Failed to save scene")
		return
	
	node2d.queue_free()
	file.close()

	

func _to_grid_position(mouse_pos):
	var x = int(floor(mouse_pos.x / TILE_SIZE))
	var y = int(floor(mouse_pos.y / TILE_SIZE))
	if x < 0 or x >= GRID_WIDTH or y < 0 or y >= GRID_HEIGHT:
		print("Mouse out of bounds")
		return null
	return Vector2(x, y)

func _get_tile_data(x, y):
	if x < 0 or x >= GRID_WIDTH or y < 0 or y >= GRID_HEIGHT:
		return null
	return grid[y][x]

func _set_tile_data(x, y, tile_id):
	if x < 0 or x >= GRID_WIDTH or y < 0 or y >= GRID_HEIGHT:
		return
	grid[y][x] = tile_id

func _draw_grid():
	for y in range(GRID_HEIGHT + 1):
		var line = Line2D.new()
		line.width = LINE_WIDTH
		line.add_point(Vector2(0, y * TILE_SIZE))
		line.add_point(Vector2(GRID_WIDTH * TILE_SIZE, y * TILE_SIZE))
		add_child(line)

	for x in range(GRID_WIDTH + 1):
		var line = Line2D.new()
		line.width = LINE_WIDTH
		line.add_point(Vector2(x * TILE_SIZE, 0))
		line.add_point(Vector2(x * TILE_SIZE, GRID_HEIGHT * TILE_SIZE))
		add_child(line)

		_update_grid()

func _on_spin_box_value_changed(value:float):
	GRID_HEIGHT = value
	GRID_WIDTH = value


func _on_button_pressed():
	_draw_grid()
	get_child(0).get_child(0).visible = false


func _on_file_dialog_files_selected(paths:PackedStringArray):
	if paths.size() == 1:
		var tileset = load(paths[0])
		var tileset_instance = tileset.instantiate()
		tileset_instance.visible = false
		for i in tileset_instance.get_children():
			tiles.append(i)
			add_child(i)
			get_node("CanvasLayer/ItemList").add_item(i.name, i.get_node("Sprite2D").texture)
	else:
		for path in paths:
			var tile = load(path)
			var instance = tile.instantiate()
			instance.visible = false
			tiles.append(instance)
			add_child(instance)
			get_node("CanvasLayer/ItemList").add_item(instance.name, instance.get_node("Sprite2D").texture)
	get_node("FileDialog").visible = false
	get_node("CanvasLayer/ItemList").visible = true

func _on_button_2_pressed():
	get_node("FileDialog").visible = true

func _on_item_selected(index):
	print("Selected item", index)
	selected_tile = tiles[index]
	selected_index = index

func _load_tileset():
	var fd = get_node("FileDialog")
	fd.visible = true
	fd.clear_filters()
	fd.add_filter("*.tscn")



func _on_item_list_mouse_entered():
	block_click = true


func _on_item_list_mouse_exited():
	block_click = false


func _on_item_list_2_item_selected(index):
	selected_obstacle = obstacles[index - 1]


func _on_check_box_2_toggled(toggled_on):
	get_node("CanvasLayer/ItemList2").deselect_all()
	creature_spawn = toggled_on

func _on_check_box_toggled(toggled_on):
	get_node("CanvasLayer/ItemList2").deselect_all()
	player_spawn = toggled_on

func _on_button_3_pressed():
	_save_grid_to_file(true)

func _on_button_4_pressed():
	for i in get_node('tiles').get_children():
		i.queue_free()
	_update_grid()
