extends Node
@export var begin_time = 5
@export var wave_end_time = 5
@export var ability_time = 5
@export var shop_time = 20
signal next_wave()
signal next_choice(unit)
signal next_shop(time)
signal update_characters()
signal start_encounter(value, completed_waves, unit)
signal start_singleplayer()
var round_list = ['PVA', 'PVE', 'PVA', 'END']
var timer
var current_round
var round_number = 0
var units = []

func _next_round():
	current_round = round_list[round_number]
	round_number += 1
	
	match current_round:
		'END':
			print('win')
		'PVE':
			Utility.get_node('Transition')._start(2)
			await get_tree().create_timer(0.5).timeout
			next_wave.emit()
		'PVA':
			Utility.get_node('Transition')._start(2)
			await get_tree().create_timer(0.5).timeout
			next_choice.emit()
		'PVS':
			Utility.get_node('Transition')._start(2)
			await get_tree().create_timer(0.5).timeout
			next_shop.emit(shop_time)

func _next_area(area, value):
	if area == 'Town':
		Utility.get_node('Transition')._start(2)
		await get_tree().create_timer(0.5).timeout
		Utility.get_node('Brightness')._set_fog_layer(-2)
		Utility.get_node('Brightness')._set_color(Color8(136, 158, 151))
		GameManager.save_game()
		start_singleplayer.emit()
	if area == 'Combat':
		Utility.get_node('Transition')._start(2)
		await get_tree().create_timer(0.5).timeout
		start_encounter.emit(value, units[0]._get_completed_waves(), units[0])
	if area == 'Ability':
		next_choice.emit(units[0])
		
func _create_timer(time):
	timer = Timer.new()
	timer.timeout.connect(_on_timer_timeout)
	timer.set_wait_time(time)
	add_child(timer)
	timer.start()
	
func _update_player_characters():
	for unit in units:
		if unit.c_name == 'Explorer':
			update_characters.connect(unit._level_up)
		
func _start_manager():
	_create_timer(begin_time)
	
func _on_timer_timeout():
	#_next_round()
	timer.stop()
	
func _on_start_round_manager():
	if GameManager.is_singleplayer:
		if GameManager.is_save_file:
			_next_area('Town', null)
		else:
			_next_area('Ability', null)
	else:
		_start_manager()

func _on_ability_manager_picked(_ability):
	_next_area('Town', null)

func _on_shop_closed():
	_next_round()

func _on_character_selected(unit):
	units.append(unit)
	_update_player_characters()
	
func _on_stop_wave(completed, wave):
	#_create_timer(wave_end_time)
	if GameManager.is_singleplayer:
		if completed:
			_next_area('Town', null)
		else:
			units[0]._add_completed_wave(wave)
			_next_area('Ability', null)
			update_characters.emit()

func _on_ability_manager_curse_picked(curse:Variant):
	Utility.get_node('Transition')._start(0.3)
	start_singleplayer.emit()
	_next_area('Town', null)

func _on_ability_manager_enchantment_picked(enchantment:Variant, unit, value = true):
	if value:
		Utility.get_node('Transition')._start(0.3)
		_next_area('Town', null)
	update_characters.emit()
