extends Node
@export var teleporter_list : PackedScene
@export var wave_list : PackedScene
signal _on_finished()
var tp_list
var w_list
var interacting = false

func _initialize():
	var player = get_tree().get_nodes_in_group('players')[0]
	var completed
	w_list = wave_list.instantiate()
	tp_list = teleporter_list.instantiate()
	for child in w_list.get_children():
		if child.name in player._get_completed_waves():
			completed = true
		else:
			completed = false
		var item = tp_list.get_child(0).add_item(child.name, null, true)
		var tooltip = child._get_tooltip()
		tooltip += ' Completed: ' + str(completed)
		tp_list.get_child(0).set_item_tooltip(item, tooltip)
	w_list.queue_free()
	tp_list.name = 'list_1'
	add_child(tp_list)
	tp_list.get_child(0).item_selected.connect(_change_level)

func _use(enable):
	if enable:
		var player = get_tree().get_nodes_in_group('players')[0]
		get_node('list_1').get_child(0).visible = true
		var list = get_node('list_1').get_child(0)
		for i in player._get_completed_waves():
			var new_tooltip = remove_part(list.get_item_tooltip(i), ' Completed: false')
			new_tooltip += ' Completed: true'
			list.set_item_tooltip(i, new_tooltip)
		if player._is_all_waves_completed():
			get_node('list_1').get_child(1).visible = true
		else:
			get_node('list_1').get_child(1).visible = false
		interacting = true
	else:
		get_node('list_1').get_child(0).visible = false
		interacting = false

func _get_interacting():
	return interacting

func _change_level(index):
	_on_finished.emit(index)

func remove_part(original: String, to_remove: String) -> String:
	var start_index = original.find(to_remove)
	if start_index == -1:
		return original  # Substring not found
	var end_index = start_index + to_remove.length()
	return original.substr(0, start_index) + original.substr(end_index, original.length() - end_index)
	
	
