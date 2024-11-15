extends Node
@export var teleporter_list : PackedScene
@export var wave_list : PackedScene
signal _on_finished()
signal _calculate_ascend_power(first_wave, last_wave)
var tp_list
var w_list
var interacting = false

var first_wave_stats = {}
var last_wave_stats = {}

var map_information = {}
var total_waves = 0

func _initialize():
	var player = get_tree().get_nodes_in_group('players')[0]
	w_list = wave_list.instantiate()
	tp_list = teleporter_list.instantiate()
	_calculate_ascend_power.connect(tp_list.get_child(1)._on_ascend)

	var wave_number = 0

	first_wave_stats = {
		'health': w_list.get_child(0).get_child(0).base_health,
		'armor': w_list.get_child(0).get_child(0).base_armor,
		'damage': w_list.get_child(0).get_child(0).base_attack_damage
	}

	last_wave_stats = {
		'health': w_list.get_child(w_list.get_child_count() - 1).get_child(0).base_health,
		'armor': w_list.get_child(w_list.get_child_count() - 1).get_child(0).base_armor,
		'damage': w_list.get_child(w_list.get_child_count() - 1).get_child(0).base_attack_damage
	}

	for child in w_list.get_children():
		wave_number += 1

		map_information[wave_number - 1] = {
			'wave_name': child.wave_name,
			'tooltip': child.tooltip,
			'icon': child.icon
		}
		if wave_number == 2 or wave_number == 1 or player._get_completed_waves().find(wave_number-1) != -1:
			tp_list.get_child(0).get_child(0).add_item(child.name, null, true)
		else:
			tp_list.get_child(0).get_child(0).add_item(child.name, null, false)
	add_child(tp_list)
	if tp_list.get_child(1) != null:
		_calculate_ascend_power.emit(first_wave_stats, last_wave_stats)
		tp_list.get_child(1)._initialize(player)

	w_list.queue_free()
	tp_list.name = 'list_1'
	tp_list.get_child(0).get_child(0).item_selected.connect(_open_tooltip)

func _use(enable):
	if enable:
		var player = get_tree().get_nodes_in_group('players')[0]
		get_node('list_1').get_child(0).get_child(0).deselect_all()
		get_node('list_1').get_child(0).visible = true
		if player._is_all_waves_completed():
			get_node('list_1').get_child(1).visible = true
			get_node('list_1').get_child(0).visible = false
			get_node('list_1').get_node('Maps').visible = false
		else:
			get_node('list_1').get_child(1).visible = false
		interacting = true
	else:
		get_node('list_1').get_child(0).visible = false
		get_node('list_1').get_child(1).visible = false
		get_node('list_1').get_node('Maps').visible = false
		interacting = false

func _get_interacting():
	return interacting

func _change_level(index):
	_on_finished.emit(index)

func _open_tooltip(index):
	get_node('list_1').get_node('Maps').get_node('Title').text = "[center]" + map_information[index].wave_name
	get_node('list_1').get_node('Maps').get_node('Tooltip').text = "[center]" + map_information[index].tooltip
	get_node('list_1').get_node('Maps').get_node('Icon').texture = map_information[index].icon

	if get_node('list_1').get_node('Maps').get_node('Enter').is_connected('pressed', _change_level):
		get_node('list_1').get_node('Maps').get_node('Enter').disconnect('pressed', _change_level)
		
	get_node('list_1').get_node('Maps').get_node('Enter').pressed.connect(_change_level.bind(index))
	get_node('list_1').get_node('Maps').visible = true

func remove_part(original: String, to_remove: String) -> String:
	var start_index = original.find(to_remove)
	if start_index == -1:
		return original  # Substring not found
	var end_index = start_index + to_remove.length()
	return original.substr(0, start_index) + original.substr(end_index, original.length() - end_index)
	
	
