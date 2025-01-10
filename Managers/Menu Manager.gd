extends Node
var start_button
var singleplayer_button
var transition
var players = {}
var store_panel
@export var transition_time = 3
var player_info = {"name": "Name",
"character" : "Explorer"}

const DEFAULT_SERVER_IP = "127.0.0.1"
var players_loaded = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	store_panel = get_child(0).get_node('StorePanel')

func _input(event):
	if event.is_action_pressed("Ability_1"):
		print("Saving game")
		GameManager.save_game('user://ascension.save')
	if event.is_action_pressed("Ability_2"):
		print(Utility.get_node('AscensionBalance')._get_balance())
		get_node('AC').load()

func _process(delta):
	get_node('CanvasLayer/LoadButton').visible = FileAccess.file_exists("user://savegame.save")

func _button_pressed():
	_singleplayer()

func _singleplayer():
	Utility.get_node('Transition')._start(2)
	await get_tree().create_timer(0.5).timeout
	GameManager._change_scene('res://Scenes/Cinematics/Start_cinematic.tscn', true)

func _quick_start():
	GameManager.selected_character_name = "Explorer"
	GameManager.new_game()

func _open_store():
	if store_panel.visible:
		store_panel.visible = false
	else:
		store_panel.visible = true
		print(Utility.get_node('AscensionBalance')._get_balance())
		get_node('AC').load()
		store_panel.get_node('AC_Current').text = "[center]Current: " + str(Utility.get_node('AscensionStats')._get_bonus_ascension_gain()) + "x.[/center]" 
		store_panel.get_node('XP_Current').text = "[center]Current: " + str(Utility.get_node('AscensionStats')._get_bonus_xp_gain()) + "x.[/center]"
		store_panel.get_node('Drop_Current').text = "[center]Current: " + str(Utility.get_node('AscensionStats')._get_bonus_drop_rate()) + "x.[/center]"
		store_panel.get_node('AC_Cost').text = "[center]Cost: " + str(Utility.get_node('AscensionStats')._get_bonus_ascension_price()) + "AC.[/center]"
		store_panel.get_node('XP_Cost').text = "[center]Cost: " + str(Utility.get_node('AscensionStats')._get_bonus_xp_price()) + "AC.[/center]"
		store_panel.get_node('Drop_Cost').text = "[center]Cost: " + str(Utility.get_node('AscensionStats')._get_bonus_drop_rate_price()) + "AC.[/center]"
		store_panel.get_node('RichTextLabel').text = "[center]Total Ascension Currency: " + str(Utility.get_node('AscensionBalance')._get_balance()) + "AC.[/center]"

func _buy_ascension_currency():
	if Utility.get_node('AscensionStats')._get_bonus_ascension_gain() >= 20:
		return
	if Utility.get_node('AscensionBalance')._get_balance() >= Utility.get_node('AscensionStats')._get_bonus_ascension_price():
		Utility.get_node('AscensionBalance')._remove_balance(Utility.get_node('AscensionStats')._get_bonus_ascension_price())
		Utility.get_node('AscensionStats')._add_bonus_ascension_gain(0.2)
		Utility.get_node('AscensionStats')._set_bonus_ascension_price()
		store_panel.get_node('AC_Current').text = "[center]Current: " + str(Utility.get_node('AscensionStats')._get_bonus_ascension_gain()) + "x.[/center]" 
		store_panel.get_node('AC_Cost').text = "[center]Cost: " + str(Utility.get_node('AscensionStats')._get_bonus_ascension_price()) + "AC.[/center]"
		store_panel.get_node('RichTextLabel').text = "[center]Total Ascension Currency: " + str(Utility.get_node('AscensionBalance')._get_balance()) + "AC.[/center]"
		GameManager.save_game('user://ascension.save')

func _buy_xp_gain():
	if Utility.get_node('AscensionStats')._get_bonus_xp_gain() >= 20:
		return
	if Utility.get_node('AscensionBalance')._get_balance() >= Utility.get_node('AscensionStats')._get_bonus_xp_price():
		Utility.get_node('AscensionBalance')._remove_balance(Utility.get_node('AscensionStats')._get_bonus_xp_price())
		Utility.get_node('AscensionStats')._add_bonus_xp_gain(0.2)
		Utility.get_node('AscensionStats')._set_bonus_xp_price()
		store_panel.get_node('XP_Current').text = "[center]Current: " + str(Utility.get_node('AscensionStats')._get_bonus_xp_gain()) + "x.[/center]"
		store_panel.get_node('XP_Cost').text = "[center]Cost: " + str(Utility.get_node('AscensionStats')._get_bonus_xp_price()) + "AC.[/center]"
		store_panel.get_node('RichTextLabel').text = "[center]Total Ascension Currency: " + str(Utility.get_node('AscensionBalance')._get_balance()) + "AC.[/center]"
		GameManager.save_game('user://ascension.save')

func _buy_drop_rate():
	if Utility.get_node('AscensionStats')._get_bonus_drop_rate() >= 30:
		return
	if Utility.get_node('AscensionBalance')._get_balance() >= Utility.get_node('AscensionStats')._get_bonus_drop_rate_price():
		Utility.get_node('AscensionBalance')._remove_balance(Utility.get_node('AscensionStats')._get_bonus_drop_rate_price())
		Utility.get_node('AscensionStats')._add_bonus_drop_rate(0.2)
		Utility.get_node('AscensionStats')._set_bonus_drop_rate_price()
		store_panel.get_node('Drop_Current').text = "[center]Current: " + str(Utility.get_node('AscensionStats')._get_bonus_drop_rate()) + "x.[/center]"
		store_panel.get_node('Drop_Cost').text = "[center]Cost: " + str(Utility.get_node('AscensionStats')._get_bonus_drop_rate_price()) + "AC.[/center]"
		store_panel.get_node('RichTextLabel').text = "[center]Total Ascension Currency: " + str(Utility.get_node('AscensionBalance')._get_balance()) + "AC.[/center]"
		GameManager.save_game('user://ascension.save')

func _close_store():
	store_panel.visible = false

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

func _load_game():
	GameManager.load_game()
		
func _change_level(scene: PackedScene):
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	level.add_child(scene.instantiate())

func _exit_game():
	get_tree().quit()
