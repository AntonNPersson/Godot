extends Node
signal respawn_creatures(value)
signal next_sub_wave(subwave, wave)
signal stop_wave(completed, wave)
signal start_boss(value, wave)
signal start_wave(value, wave)
signal get_units(unit)

@export var portal_effect : PackedScene

var players = []
var waves
var current_wave
var current_wave_scene
var current_boss
var current_round = 0
var current_amount_of_enemies = 999
var total_amount_of_enemies = 999
var wave_ongoing = false
var boss_ready = false
var completed_waves = []
var sub_waves = 0
var current_sub_wave = []
var chosen_sub_wave = 0
var wave_counter = 0
var current_wave_counter = 1

const RESET_ENEMY = 999
const SUB_WAVE_THRESHHOLD = 1
const INCEPTION_WAVE_THRESHHOLD = 2
const WAVE_COUNTDOWN_TIME = 3
const START_COUNTDOWN_TIME = 4

var canvas
var time_left = -1
enum maps{ROOM, BOSS, WAVE}
var next_map = maps.ROOM

var curses = []

func _ready():
	waves = get_node('Waves')
	canvas = get_node('CanvasLayer')



func _process(_delta):
	if time_left > 0:
		time_left -= get_process_delta_time()
		canvas.get_child(2).visible = true
		canvas.get_child(2).text = str(int(time_left))
	else:
		canvas.get_child(2).visible = false

	if wave_ongoing:
		_update_objectives()
	else:
		canvas.get_node('RichTextLabel2').visible = false

	if current_amount_of_enemies <= 0:
		if boss_ready:
			var portal_effect = portal_effect.instantiate()
			portal_effect.modulate = Color.GREEN
			get_tree().get_root().add_child(portal_effect)
			portal_effect.global_position = players[0].global_position
			portal_effect.enter_portal.connect(_enter_portal_exit)
			current_amount_of_enemies = RESET_ENEMY

	if wave_ongoing:
		if current_wave.has_meta('Special'):
			current_wave._get_special()

func _start_wave(value, last = false):
	current_round = value
	current_wave_scene = load("res://Waves/wave_" + str(current_round) +".tscn")
	current_wave = current_wave_scene.instantiate()
	waves.add_child(current_wave)
	current_wave.visible = true
	for child in current_wave.get_children():
		child._ascend()
		for curse in curses:
			child._add_stats(curse)
		child.is_dead.connect(_unit_dead)
		child.paused = true
		child.visible = false
		child.global_position = Vector2(-10000, -10000)
	get_units.emit(current_wave.get_children())
	players[0].in_combat = false
	
	if current_wave.has_meta('Color'):
		Utility.get_node('Brightness')._set_color(current_wave.get_meta('Color'))

	if !last:
		wave_counter = randi_range(2, 3)
		start_wave.emit(current_wave, value)
		canvas.get_child(2).visible = true
		time_left = START_COUNTDOWN_TIME
		await get_tree().create_timer(START_COUNTDOWN_TIME).timeout
		canvas.get_child(2).visible = false
		players[0].in_combat = true
	else:
		wave_counter = randi_range(2, 3)
		next_sub_wave.emit(chosen_sub_wave, value)
		time_left = START_COUNTDOWN_TIME
		await get_tree().create_timer(START_COUNTDOWN_TIME).timeout
		canvas.get_child(2).visible = false
		players[0].in_combat = true
	wave_ongoing = true

func _unit_dead(_unit):
	current_amount_of_enemies -= 1

	if current_amount_of_enemies == INCEPTION_WAVE_THRESHHOLD:
		if current_wave_counter < wave_counter:
			current_wave_counter += 1
			time_left = WAVE_COUNTDOWN_TIME
			next_map = maps.WAVE
			await get_tree().create_timer(WAVE_COUNTDOWN_TIME).timeout
			respawn_creatures.emit(current_round)
			return
		else:
			current_amount_of_enemies = SUB_WAVE_THRESHHOLD

		if current_sub_wave.size() >= SUB_WAVE_THRESHHOLD:
			canvas.get_node('RichTextLabel2').visible = false
			chosen_sub_wave = current_sub_wave.pop_front()
			next_map = maps.ROOM
			current_wave_counter = 1
			var portal_effect = portal_effect.instantiate()
			get_tree().get_root().add_child(portal_effect)
			portal_effect.global_position = _unit.global_position
			portal_effect.enter_portal.connect(_enter_portal)
		else:
			next_map = maps.BOSS
			var portal_effect = portal_effect.instantiate()
			portal_effect.modulate = Color.RED
			get_tree().get_root().add_child(portal_effect)
			portal_effect.global_position = _unit.global_position
			portal_effect.enter_portal.connect(_enter_portal_boss)

func _enter_portal():
	_start_wave(current_round, true)

func _enter_portal_boss():
	_start_boss()

func _enter_portal_exit():
	_stop_wave()

func _next_wave_countdown():
	respawn_creatures.emit(current_round)
	canvas.get_child(2).visible = false
	canvas.get_child(3).visible = false
	time_left = WAVE_COUNTDOWN_TIME

func _stop_wave():
	wave_ongoing = false
	waves.remove_child(current_boss)
	players[0].in_combat = false
	if current_round in completed_waves:
		stop_wave.emit(true, current_round)
	else:
		stop_wave.emit(false, current_round)

func _start_boss():
	var current_boss_scene = load("res://Waves/boss/boss_" + str(current_round) +".tscn")
	current_boss = current_boss_scene.instantiate()
	waves.add_child(current_boss)
	get_units.emit(current_boss.get_children())
	current_amount_of_enemies = current_boss.get_child_count()
	for child in current_boss.get_children():
		child._ascend()
		for curse in curses:
			child._add_stats(curse)
		child.is_dead.connect(_unit_dead)
		waves.add_child(current_boss)
	
	start_boss.emit(current_boss, current_round)
	wave_ongoing = true
	boss_ready = true
	players[0].in_combat = true


func _on_next_wave():
	current_round += 1
	_start_wave(current_round)

func _on_round_manager_start_encounter(value, _completed_waves, player):
	players.append(player)
	_start_wave(value)
	current_sub_wave = []
	sub_waves = -1
	var dir = DirAccess.open('res://Maps/Tiles/Arena_'+ str(value) + '/Layouts/')
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if file.ends_with('.txt'):
			sub_waves += 1
			current_sub_wave.append(sub_waves)
	current_round = value
	wave_counter = randi_range(2, 3)
	current_sub_wave.erase(0)
	print(_completed_waves)
	completed_waves.clear()
	completed_waves.append_array(_completed_waves)
	players[0].in_combat = true

func _on_map_manager_used_creatures(number:Variant, arr:Variant):
	for child in arr:
		child.is_dead.connect(_unit_dead)
	current_amount_of_enemies = number + 2
	total_amount_of_enemies = number
	_update_objectives()

func _get_total_waves():
	return 2

func _update_objectives():
	canvas.get_node('RichTextLabel2').visible = true
	canvas.get_node('RichTextLabel2').text = 'Waves: ' + str(current_wave_counter) + '/' + str(wave_counter)

func _update_ascension_info():
	canvas.get_node('Ascension3').get_child(0).play('Ascension_anim')
	canvas.get_node('Ascension').text = 'Ascension: ' + str(players[0].ascension_level)
	var aggregated_tooltip = {}
	for curse in curses:
		if aggregated_tooltip.has(curse.second_tooltip):
			aggregated_tooltip[curse.second_tooltip] += 1
		else:
			aggregated_tooltip[curse.second_tooltip] = 1
	canvas.get_node('Ascension2').text = ''
	for key in aggregated_tooltip.keys():
		canvas.get_node('Ascension2').text += key + ' x' + str(aggregated_tooltip[key]) + '\n'
	canvas.get_node('Ascension').visible = true
	canvas.get_node('Ascension2').visible = true

func _on_ability_manager_curse_picked(curse:Variant):
	curses.append(curse)
	_update_ascension_info()

