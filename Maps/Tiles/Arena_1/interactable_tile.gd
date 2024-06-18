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
	for i in tp_list.get_children():
		i.item_selected.connect(_change_level)

func _use(enable):
	if enable:
		var player = get_tree().get_nodes_in_group('players')[0]
		get_node('list_1').get_child(0).visible = true
		var list = get_node('list_1').get_child(0)
		for i in list.get_children():
			if i.text in player._get_completed_waves():
				i.set_item_tooltip(i, i.get_tooltip().replace('Completed: false', 'Completed: true'))
		interacting = true
	else:
		get_node('list_1').get_child(0).visible = false
		interacting = false

func _get_interacting():
	return interacting

func _change_level(index):
	_on_finished.emit(index)
	
	
