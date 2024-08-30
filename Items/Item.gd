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
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[center][color=Mistyrose]' + get_child(2).name + '[/color][/center]'
		tooltip_name.modulate = Color.MISTY_ROSE
		get_child(1).color = Color.MISTY_ROSE
		get_child(1).get_child(0).color = Color.MISTY_ROSE
		tooltip_icon.get_child(1).modulate = Color.MISTY_ROSE
	elif rarity == ITEM_RARITY.UNCOMMON:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Limegreen]' + get_child(2).name + '[/color]'
		tooltip_name.modulate = Color.LIME_GREEN
		get_child(1).color = Color.LIME_GREEN
		get_child(1).get_child(0).color = Color.LIME_GREEN
		tooltip_icon.get_child(1).modulate = Color.LIME_GREEN
	elif rarity == ITEM_RARITY.RARE:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Steelblue]' + get_child(2).name + '[/color]'
		tooltip_name.modulate = Color.STEEL_BLUE
		get_child(1).color = Color.STEEL_BLUE
		get_child(1).get_child(0).color = Color.STEEL_BLUE
		tooltip_icon.get_child(1).modulate = Color.STEEL_BLUE
	elif rarity == ITEM_RARITY.EPIC:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Mediumorchid]' + get_child(2).name + '[/color]'
		tooltip_name.modulate = Color.MEDIUM_ORCHID
		get_child(1).color = Color.MEDIUM_ORCHID
		get_child(1).get_child(0).color = Color.MEDIUM_ORCHID
		tooltip_icon.get_child(1).modulate = Color.MEDIUM_ORCHID
	elif rarity == ITEM_RARITY.LEGENDARY:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Coral]' + get_child(2).name + '[/color]'
		tooltip_name.modulate = Color.CORAL
		get_child(1).color = Color.CORAL
		get_child(1).get_child(0).color = Color.CORAL
		tooltip_icon.get_child(1).modulate = Color.CORAL

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
			if valu == 2:
				tooltip_main_desc.text = tag + ": " + str(value)
				continue

		if value != 0:
			if tag in tag_values:
				tag_values[tag] += value
			else:
				tag_values[tag] = value
			for ta in tag_values:
				value = tag_values[ta]
			if "increased" in tag.to_lower() or "cooldown" in tag.to_lower() or "chance" in tag.to_lower():
				var string = tag + ": " + str(value) + "%"
				toolt += string + "\n"
			else:
				var string = tag + ": " + str(value)
				toolt += string + "\n"

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
				get_child(0).get_child(0).visible = false
				get_child(0).get_child(1).visible = false
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
	get_child(0).get_child(1).visible = true
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
	get_child(0).get_child(0).modulate.a = 0.6
	get_child(0).get_child(1).get_child(0).modulate.a = 1
	player.lose_camera_focus = true


func _on_panel_2_mouse_exited():
	get_child(0).get_child(0).visible = false
	get_child(0).get_child(1).get_child(0).modulate.a = 0.5
	player.lose_camera_focus = false

func _show_tooltip_at_mouse():
	get_child(0).get_child(0).global_position = get_viewport().get_mouse_position() - Vector2(get_child(0).get_child(0).size.x/2, get_child(0).get_child(0).size.y + 10)
	get_child(0).get_child(0).modulate.a = 1

	var viewport_size = get_viewport().size
	if get_child(0).get_child(0).global_position.x + get_child(0).get_child(0).size.x > viewport_size.x:
		get_child(0).get_child(0).global_position.x = viewport_size.x - get_child(0).get_child(0).size.x
	
	if get_child(0).get_child(0).global_position.y + get_child(0).get_child(0).size.y > viewport_size.y:
		get_child(0).get_child(0).global_position.y = viewport_size.y - get_child(0).get_child(0).size.y
	


func _unhandled_input(event):
	if get_child(0).get_child(0).visible == false:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_panel.scroll_vertical -= 3
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_panel.scroll_vertical += 3
