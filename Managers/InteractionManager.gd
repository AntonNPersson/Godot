extends Node
var interactRange = 100.0
var players_arr = []
var offset = Vector2(0, -84)
var distance
var hold_timer = 0.0
@export var popup_ : PackedScene
signal call_wave_manager(value)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_interactable_action()
	_special_action()
	_interactable_hold_action(_delta)



func _special_action():
	for obj in Utility.get_node('Interactable').special_objects:
		if obj and is_instance_valid(obj):
			obj._get_special()

func _interactable_action():
	for obj in Utility.get_node('Interactable').interactable_objects:
		if is_instance_valid(obj):
			var players = get_tree().get_nodes_in_group('players')
			var in_range = false
			for player in players:
				distance = player.global_position.distance_to(obj.global_position)
				if distance <= interactRange:
					in_range = true
					if player not in players_arr:
						obj._initialize()
						
						if obj.has_node('list_1'):
							_connect_signals(obj)

						_create_ready_message(obj)
						players_arr.append(player)
					if Input.is_action_pressed('Interact'):
						obj._use(true)
			if obj.has_node('label'):
				if !obj._get_interacting():
					obj.get_node('label').visible = in_range
				else:
					obj.get_node('label').visible = false
			if !in_range and obj.has_node('list_1'):
				obj._use(false)

func _interactable_hold_action(delta):
	for obj in Utility.get_node('Interactable').interactable_objects_hold:
		if is_instance_valid(obj):
			var players = get_tree().get_nodes_in_group('players')
			var in_range = false
			for player in players:
				distance = player.global_position.distance_to(obj.global_position)
				if distance <= interactRange:
					in_range = true
					if player not in players_arr:
						obj._initialize()
						_create_ready_message(obj, true)
						players_arr.append(player)
					if Input.is_action_pressed('Interact'):
						hold_timer += delta
						if hold_timer >= 1.0:
							obj._use(true)
							hold_timer = 0.0
					if Input.is_action_just_released('Interact'):
						hold_timer = 0.0

			if obj.has_node('label'):
				if !obj._get_interacting():
					obj.get_node('label').visible = in_range
				else:
					obj.get_node('label').visible = false
func _connect_signals(obj):
	obj._on_finished.connect(_change_map)	

func _create_ready_message(player, hold = false):
	var instance = popup_.instantiate()
	instance.name = "label"
	instance.visible = false
	instance.global_position += offset
	var interact_action = InputMap.action_get_events('Interact')
	if interact_action.size() > 0:
		interact_action = remove_part(interact_action[0].as_text(), "(Physical)")
	else:
		interact_action = 'Interact'
	if hold:
		instance.get_child(0).text = "Hold " + interact_action + "to interact"
	else:
		instance.get_child(0).text = "Press " + interact_action + "to interact"
	player.add_child(instance)

func _on_changing_map():
	players_arr.clear()
	
func _change_map(value):
	call_wave_manager.emit("Combat", value+1)

func remove_part(original: String, to_remove: String) -> String:
	var start_index = original.find(to_remove)
	if start_index == -1:
		return original  # Substring not found
	var end_index = start_index + to_remove.length()
	return original.substr(0, start_index) + original.substr(end_index, original.length() - end_index)

