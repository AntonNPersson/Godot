extends Node
var start_button
var singleplayer_button
var transition
var players = {}
@export var transition_time = 3
var player_info = {"name": "Name",
"character" : "Explorer"}

const DEFAULT_SERVER_IP = "127.0.0.1"
var players_loaded = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button = get_child(1)
	singleplayer_button = get_child(2)
	start_button.pressed.connect(self._button_pressed)
	singleplayer_button.pressed.connect(self._singleplayer)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	
func _input(event):
	if event.is_action_pressed("Ability_1"):
		_quick_start()

func _button_pressed():
	start_button.visible = false
	singleplayer_button.visible = true

func _singleplayer():
	singleplayer_button.disconnect("pressed", self._singleplayer)
	Utility.get_node('Transition')._start(transition_time)
	await get_tree().create_timer(transition_time).timeout
	GameManager._change_scene('res://Scenes/Cinematics/Start_cinematic.tscn', true)

func _quick_start():
	GameManager.selected_character_name = "Explorer"
	GameManager._change_scene("res://Scenes/Game.tscn", true)

func _create_multiplayer():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(7070, 1)
	multiplayer.multiplayer_peer = peer
	players[1] = player_info
	GameManager.selected_character_name = players[1].character
	_start_game()

func _join_multiplayer():
	var address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, 7070)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
	
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	GameManager.selected_character_name = players[peer_id].character
	GameManager._change_scene("res://Scenes/Game.tscn", false)
	
func _on_connected_fail():
	print('hi')
	multiplayer.multiplayer_peer = null
	
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	GameManager.selected_character_name = players[2].character
	GameManager._change_scene("res://Scenes/Game.tscn", false)
	
func _start_game():
	if multiplayer.is_server():
		get_child(0).visible = false
		get_child(1).visible = false
		_change_level.call_deferred(load("res://Scenes/Game.tscn"))
		
func _change_level(scene: PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())
