extends Node
var z_index = 0
var tile_walkable = true
var tile_interactable = false
var tile_special = false
var tile_sprite = null
var tile_name = ''
var tile_boss = false
var tile_mob = false
var tile_player = false

var packed_scenes = []
var instances = []

@onready var parent = get_parent()
@onready var grandparent = parent.get_parent()
@onready var tile_texture = parent.get_node('Tile_texture')
@onready var file_dialog = parent.get_node('FileDialog')

func _process(delta):
	if file_dialog.current_path:
		tile_texture.texture = load(file_dialog.current_path)

func _create_tile():
	_update_info()
	if tile_name == '' or tile_sprite == null:
		print(tile_name + ' ' + str(tile_sprite))
		return

	print('hej')
	var tile = Area2D.new()
	tile.name = tile_name
	tile.z_index = z_index
	tile.collision_layer = 1
	tile.collision_mask = 1
	tile.set_meta('Walkable', tile_walkable)
	tile.set_meta('Interactable', tile_interactable)
	tile.set_meta('Special', tile_special)

	if tile_boss:
		tile.set_meta('Boss_Spawn', tile_boss)
	if tile_mob:
		tile.set_meta('Mob_Spawn', tile_mob)
	if tile_player:
		tile.set_meta('Player_Spawn', tile_player)

	var sprite = Sprite2D.new()
	sprite.name =  "Sprite2D"
	sprite.texture = tile_sprite
	tile.add_child(sprite)
	sprite.set_owner(tile)

	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(64, 64)
	collision.shape = shape
	tile.add_child(collision)
	collision.set_owner(tile)
	
	if !tile_walkable:
		var light_occluder = LightOccluder2D.new()
		var occluder = OccluderPolygon2D.new()
		occluder.polygon = [Vector2(-64, -64), Vector2(64, -64), Vector2(64, 64), Vector2(-64, 64)]
		light_occluder.light_mask = 1
		light_occluder.occluder = occluder
		tile.add_child(light_occluder)
		light_occluder.set_owner(tile)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(tile)
	ResourceSaver.save(packed_scene, 'res://Tool/Created Tiles/' + tile_name + '.tscn')
	tile.queue_free()

func _select_tile(index):
	parent.get_node('Name').text = instances[index].name
	parent.get_node('z_index').value = instances[index].z_index
	parent.get_node('Walkable').button_pressed = instances[index].get_meta('Walkable')
	parent.get_node('Interactable').button_pressed  = instances[index].get_meta('Interactable')
	parent.get_node('Special').button_pressed  = instances[index].get_meta('Special')
	tile_texture.texture = instances[index].get_node('Sprite2D').texture

func _update_info():
	tile_name = parent.get_node('Name').text
	z_index = parent.get_node('z_index').value
	tile_walkable = parent.get_node('Walkable').button_pressed
	tile_interactable = parent.get_node('Interactable').button_pressed
	tile_special = parent.get_node('Special').button_pressed
	tile_boss = parent.get_node('boss_spawn').button_pressed
	tile_mob = parent.get_node('mob_spawn').button_pressed
	tile_player = parent.get_node('player_spawn').button_pressed

func _on_file_dialog_file_selected(path):
	tile_sprite = load(path)
	tile_texture.texture = tile_sprite
