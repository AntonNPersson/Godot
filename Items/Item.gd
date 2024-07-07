extends Node2D
@export var i_name = "Item"
var player
var rarity
var im

signal picked_up(item)
var _picked_up = false

const ITEM_RARITY = {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	EPIC = 3,
	LEGENDARY = 4
}

var tooltip = ""
var tooltip_name
var tooltip_main_desc
var tooltip_sub_desc
var tooltip_icon

var scroll_panel
var json_string

func _create_json_string(t_name, t_main_desc, t_sub_desc, t_icon, t_rarity):
	var json = {
		"tooltip_name": t_name,
		"tooltip_main_desc": t_main_desc,
		"tooltip_sub_desc": t_sub_desc,
		"tooltip_icon": t_icon,
		"rarity": t_rarity
	}
	return JSON.stringify(json)

func _initialize():
	tooltip_name = get_child(0).get_child(0).get_child(0).get_child(0)
	tooltip_main_desc = get_child(0).get_child(0).get_child(0).get_child(1)
	tooltip_sub_desc = get_child(0).get_child(0).get_child(1).get_child(0).get_child(0)
	tooltip_icon = get_child(0).get_child(0).get_child(2)
	scroll_panel = get_child(0).get_child(0).get_child(1).get_child(0)

	get_child(0).get_child(1).global_position = get_global_transform_with_canvas().get_origin()
	get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[center]' + get_child(2).name
	if get_child(2).icon != null:
		tooltip_icon.get_child(0).texture = get_child(2).icon

	tooltip_name.text = i_name
	if rarity == ITEM_RARITY.COMMON:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[center][color=white]' + get_child(2).name + '[/color][/center]'
		tooltip_name.modulate = Color(1, 1, 1)
		get_child(1).color = Color.WHITE
		get_child(1).get_child(0).color = Color.WHITE
		tooltip_icon.get_child(1).modulate = Color.WHITE
	elif rarity == ITEM_RARITY.UNCOMMON:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Lawngreen]' + get_child(2).name + '[/color]'
		tooltip_name.modulate = Color.LAWN_GREEN
		get_child(1).color = Color.LAWN_GREEN
		get_child(1).get_child(0).color = Color.LAWN_GREEN
		tooltip_icon.get_child(1).modulate = Color.LAWN_GREEN
	elif rarity == ITEM_RARITY.RARE:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Dodgerblue]' + get_child(2).name + '[/color]'
		tooltip_name.modulate = Color.DODGER_BLUE
		get_child(1).color = Color.DODGER_BLUE
		get_child(1).get_child(0).color = Color.DODGER_BLUE
		tooltip_icon.get_child(1).modulate = Color.DODGER_BLUE
	elif rarity == ITEM_RARITY.EPIC:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Blueviolet]' + get_child(2).name + '[/color]'
		tooltip_name.modulate = Color.BLUE_VIOLET
		get_child(1).color = Color.BLUE_VIOLET
		get_child(1).get_child(0).color = Color.BLUE_VIOLET
		tooltip_icon.get_child(1).modulate = Color.BLUE_VIOLET
	elif rarity == ITEM_RARITY.LEGENDARY:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Darkorange]' + get_child(2).name + '[/color]'
		tooltip_name.modulate = Color.DARK_ORANGE
		get_child(1).color = Color.DARK_ORANGE
		get_child(1).get_child(0).color = Color.DARK_ORANGE
		tooltip_icon.get_child(1).modulate = Color.DARK_ORANGE

	tooltip += _create_tooltip(2)
	if rarity >= ITEM_RARITY.UNCOMMON:
		tooltip += _create_tooltip(3)
		tooltip += _create_tooltip(4)
	if rarity >= ITEM_RARITY.RARE:
		tooltip += _create_tooltip(5)
	if rarity >= ITEM_RARITY.EPIC:
		tooltip += _create_tooltip(6)

	tooltip_sub_desc.text = tooltip

	json_string = _create_json_string(tooltip_name.text, tooltip_main_desc.text, tooltip_sub_desc.text, get_child(2).icon.resource_path, rarity)
	

func _get_random_animation():
	var anim = randi() % 4
	if anim == 0:
		return "loot_enter"
	elif anim == 1:
		return "loot_enter1"
	elif anim == 2:
		return "loot_enter_up"
	elif anim == 3:
		return "loot_enter_down"

func _play_random_animation():
	get_child(1).get_node('AnimationPlayer').play(_get_random_animation())


func _create_tooltip(valu):
	var toolt = ""
	if valu == 6:
		toolt += "\n"
		toolt += get_child(valu)._get_tooltip()
		return toolt

	var tag_values = {}
	for i in range(get_child(valu)._get_tags().size()):
		var tag = get_child(valu)._get_tags()[i]
		var value = get_child(valu)._get_values()[i]
		tag = tag.capitalize().replace("_", " ")
		if tag == "Armor" or tag == "Evade" or tag == "Barrier" or tag == "Attack Damage":
			tooltip_main_desc.text = tag + ": " + str(value)
			continue

		if value != 0:
			if tag in tag_values:
				tag_values[tag] += value
			else:
				tag_values[tag] = value
			for ta in tag_values:
				value = tag_values[ta]
			if "increased" in tag.to_lower():
				toolt += tag + ": " + "%.1f"%value + "%" + "\n"
			else:
				toolt += tag + ": " + "%.1f"%value + "\n"

	return toolt

func _input(event):
	if get_child(0).get_child(0).visible == true and _picked_up == false:
		if event.is_action_pressed('Interact'):
			if player.get_node('InventoryManager').inventory.size() < player.get_node('InventoryManager').max_slots:
				if "range" in get_child(2)._get_tags():
					if player.get_node('InventoryManager').weapon_equipped:
						Utility.get_node("ErrorMessage")._create_error_message("You already have a weapon equipped", self)
						return
				picked_up.emit(self)
				_picked_up = true
				im.remove_child(self)
				player.get_node('InventoryManager').get_node('Items').add_child(self)
				get_child(0).visible = false
				get_child(1).visible = false
				return
			else:
				Utility.get_node("ErrorMessage")._create_error_message("Inventory full", player)
				return

func _drop_item():
	_picked_up = false
	player.get_node('InventoryManager').get_node('Items').remove_child(self)
	im.add_child(self)
	global_position = player.global_position
	get_child(0).visible = true
	get_child(0).get_child(0).visible = false
	get_child(1).visible = true

func find_close_random_position():
	var pos = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	return pos


func _process(delta):
	if player == null or _picked_up == true:
		return
	
	if !_picked_up:
		get_child(0).get_child(1).global_position = get_global_transform_with_canvas().get_origin()
	
	var overlapping = get_child(0).get_child(1).get_overlapping_areas()
	for area in overlapping:
		if area.is_in_group('tooltip'):
			#resolve_overlap(get_child(0).get_child(1), area)
			break


func resolve_overlap(area1, area2):
	var rect1 = area1.get_global_rect()
	var rect2 = area2.get_global_rect()

	if rect1.intersects(rect2):
		var offset = Vector2(10, 10)  # Adjust the offset as needed
		var new_pos = area2.global_position + offset

		# Move area2 to the new position
		area2.global_position = new_pos
		
		# Recheck for further overlaps
		while area1.get_global_rect().intersects(area2.get_global_rect()):
			area2.global_position = area2.get_global_transform_with_canvas().get_origin() + offset
			area2.get_parent().get_child(0).global_position = area2.get_parent().get_global_transform_with_canvas().get_origin()

func _on_panel_2_mouse_entered():
	get_child(0).get_child(0).visible = true
	get_child(0).get_child(0).global_position = get_global_transform_with_canvas().get_origin()
	get_child(0).get_child(1).get_child(0).modulate.a = 1
	player.lose_camera_focus = true


func _on_panel_2_mouse_exited():
	get_child(0).get_child(0).visible = false
	get_child(0).get_child(1).get_child(0).modulate.a = 0.5
	player.lose_camera_focus = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_panel.scroll_vertical -= 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_panel.scroll_vertical += 1
