extends CanvasLayer
@export var enemy_sprite : Texture
@export var player_sprite : Texture
@export var npc_sprite : Texture
@export var portal_sprite : Texture
var map_manager : Node

var enemies_arr = {}
var players_arr = {}
var npcs_arr = {}
var portals_arr = {}

var is_enabled = false


# Called when the node enters the scene tree for the first time.
func _ready():
	map_manager = get_parent().get_parent().get_parent().map_manager


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_enabled:
		return
	if map_manager == null:
		map_manager = get_parent().get_parent().get_parent().map_manager

	for e in enemies_arr.keys():
		if !is_instance_valid(e) or e.is_dead:
			remove_enemy_position(e)
			continue
	
	for player in get_tree().get_nodes_in_group('players'):
		if is_instance_valid(player):
			update_player_position(player)
		else:
			players_arr.remove(player)
			get_node(str(player.name)).queue_free()

	for portal in get_tree().get_nodes_in_group('portal'):
		if is_instance_valid(portal):
			update_portal_position(portal)
		else:
			portals_arr.remove(portal)
			get_node(str(portal.name)).queue_free()

	for enemy in get_tree().get_nodes_in_group('enemies'):
		if is_instance_valid(enemy):
			update_enemy_position(enemy)
		else:
			remove_enemy_position(enemy)
			enemies_arr.erase(enemy)
			get_node(str(enemy.name)).queue_free()

func update_enemy_position(e):
	if !enemies_arr.has(e):
		var tilemap_pos = map_manager._world_to_tilemap_position(e.global_position)
		var tilemap_index = map_manager._get_tilemap_index(tilemap_pos)
		var minimap_pos = map_manager._get_minimap_position_from_index(tilemap_index)
		var player_tilemap_index = map_manager._get_tilemap_index(map_manager._world_to_tilemap_position(get_tree().get_nodes_in_group('players')[0].global_position))
		if tilemap_index == player_tilemap_index:
			return
		var sprite = Sprite2D.new()
		sprite.texture = enemy_sprite
		sprite.scale = Vector2(0.5, 0.5)
		sprite.name = e.name
		enemies_arr[e] = sprite
		add_child(sprite)
		sprite.global_position = minimap_pos
		sprite.z_index = 1
		sprite.modulate = Color(1, 0, 0, 1)
	else:
		var tilemap_pos = map_manager._world_to_tilemap_position(e.global_position)
		var tilemap_index = map_manager._get_tilemap_index(tilemap_pos)
		var minimap_pos = map_manager._get_minimap_position_from_index(tilemap_index)
		var player_tilemap_index = map_manager._get_tilemap_index(map_manager._world_to_tilemap_position(get_tree().get_nodes_in_group('players')[0].global_position))
		if tilemap_index == player_tilemap_index:
			remove_enemy_position(e)
			return
		enemies_arr[e].global_position = minimap_pos
		
		if e.is_dead:
			remove_enemy_position(e)
			return

func remove_enemy_position(e):
	if is_instance_valid(get_node(str(enemies_arr[e]))):
			get_node(str(enemies_arr[e])).queue_free()
	if enemies_arr.has(e):
		enemies_arr.erase(e)
		return

func update_player_position(p):
	if !players_arr.has(p):
		var tilemap_pos = map_manager._world_to_tilemap_position(p.global_position)
		var tilemap_index = map_manager._get_tilemap_index(tilemap_pos)
		var minimap_pos = map_manager._get_minimap_position_from_index(tilemap_index)
		var sprite = Sprite2D.new()
		sprite.texture = player_sprite
		sprite.scale = Vector2(0.5, 0.5)
		sprite.name = p.name
		players_arr[p] = sprite
		add_child(sprite)
		sprite.global_position = minimap_pos
		sprite.z_index = 2
		sprite.modulate = Color(0, 1, 0, 1)
	else:
		var tilemap_pos = map_manager._world_to_tilemap_position(p.global_position)
		var tilemap_index = map_manager._get_tilemap_index(tilemap_pos)
		var minimap_pos = map_manager._get_minimap_position_from_index(tilemap_index)
		players_arr[p].global_position = minimap_pos

func update_npc_position(n):
	if !npcs_arr.has(n):
		var tilemap_pos = map_manager._world_to_tilemap_position(n.global_position)
		var tilemap_index = map_manager._get_tilemap_index(tilemap_pos)
		if tilemap_index == Vector2(-1, -1):
			return
		var minimap_pos = map_manager._get_minimap_position_from_index(tilemap_index)
		var sprite = Sprite2D.new()
		sprite.texture = npc_sprite
		sprite.scale = Vector2(0.5, 0.5)
		sprite.name = n.name
		npcs_arr[n] = sprite
		add_child(sprite)
		sprite.global_position = minimap_pos
		sprite.z_index = 1
		sprite.modulate = Color(0, 1, 0, 1)
	else:
		var tilemap_pos = map_manager._world_to_tilemap_position(n.global_position)
		var tilemap_index = map_manager._get_tilemap_index(tilemap_pos)
		if tilemap_index == Vector2(-1, -1):
			return
		var minimap_pos = map_manager._get_minimap_position_from_index(tilemap_index)
		npcs_arr[n].global_position = minimap_pos

func update_portal_position(p):
	if !portals_arr.has(p):
		var tilemap_pos = map_manager._world_to_tilemap_position(p.global_position)
		var tilemap_index = map_manager._get_tilemap_index(tilemap_pos)
		if tilemap_index == Vector2(-1, -1):
			return
		var minimap_pos = map_manager._get_minimap_position_from_index(tilemap_index)
		var sprite = Sprite2D.new()
		sprite.texture = portal_sprite
		sprite.scale = Vector2(1, 1)
		sprite.name = p.name
		portals_arr[p] = sprite
		add_child(sprite)
		sprite.global_position = minimap_pos
		sprite.z_index = 3
		sprite.modulate = Color(1, 0, 1, 1)
	else:
		var tilemap_pos = map_manager._world_to_tilemap_position(p.global_position)
		var tilemap_index = map_manager._get_tilemap_index(tilemap_pos)
		if tilemap_index == Vector2(-1, -1):
			return
		var minimap_pos = map_manager._get_minimap_position_from_index(tilemap_index)
		portals_arr[p].global_position = minimap_pos
