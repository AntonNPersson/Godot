extends Node2D
@export var i_name = "Item"
var player
var rarity
var im
var charges = 2
var type = "Health"

signal picked_up(item)
var _picked_up = false

const ITEM_RARITY = {
	COMMON = 0,
	UNCOMMON = 1,
	RARE = 2,
	EPIC = 3,
	LEGENDARY = 4,
	UNIQUE = 5
}

var tooltip = ""
var tooltip_name
var tooltip_main_desc
var tooltip_sub_desc
var tooltip_icon
var tooltip_weapon_effect = ""

var scroll_panel
var json_string
var rarity_color = Color.WHITE

var t_v = {}

func _initialize():
	tooltip_name = get_child(0).get_child(0).get_child(0).get_child(0)
	tooltip_main_desc = get_child(0).get_child(0).get_child(0).get_child(1)
	tooltip_sub_desc = get_child(0).get_child(0).get_child(1).get_child(0).get_child(0)
	tooltip_icon = get_child(0).get_child(0).get_child(2)
	scroll_panel = get_child(0).get_child(0).get_child(1).get_child(0)

	get_child(0).get_child(1).global_position = get_global_transform_with_canvas().get_origin()
	get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[center] Potion'
	if get_child(2).icon != null:
		tooltip_icon.get_child(0).texture = get_child(2).icon

	tooltip_name.text = i_name
	if rarity == ITEM_RARITY.COMMON:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[center][color=Wheat]Potion[/color][/center]'
		rarity_color = Color.WHITE
	elif rarity == ITEM_RARITY.UNCOMMON:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Limegreen]Potion[/color]'
		rarity_color = Color.LIME_GREEN
	elif rarity == ITEM_RARITY.RARE:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Steelblue]Potion[/color]'
		rarity_color = Color.STEEL_BLUE
	elif rarity == ITEM_RARITY.EPIC:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Mediumorchid]Potion[/color]'
		rarity_color = Color.MEDIUM_ORCHID
	elif rarity == ITEM_RARITY.LEGENDARY:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=Coral]Potion[/color]'
		rarity_color = Color.CORAL
	elif rarity == ITEM_RARITY.UNIQUE:
		get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).text = '[color=CYAN]Potion[/color]'
		rarity_color = Color.CYAN

	tooltip_name.modulate = rarity_color
	get_child(1).color = rarity_color
	get_child(1).get_child(0).color = rarity_color
	tooltip_icon.get_child(1).modulate = rarity_color
	tooltip = _create_tooltip()		
	tooltip_sub_desc.text = tooltip


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


func _create_tooltip():
	var toolt = ""
	toolt += get_child(2).tooltip
	tooltip_main_desc.text = "[color=Wheat]" + str(get_child(2).heal) + " + 15% healing\n"

	if "effect" in get_child(2):
		toolt += "[color=Coral]✦ [/color]" + get_child(2).effect + "\n"
	return toolt

func _input(event):
	if get_child(0).get_child(0).visible == true and _picked_up == false:
		if event.is_action_pressed('Interact'):
			if player.get_node('InventoryManager').potions.size() < player.get_node('InventoryManager').max_potion_slots:
				picked_up.emit(self)
				_picked_up = true
				im.remove_child(self)
				player.get_node('InventoryManager').get_node('Items').add_child(self)
				get_child(0).get_child(0).visible = false
				get_child(0).get_child(1).visible = false
				get_child(1).visible = false
				return
			else:
				if player.get_node('InventoryManager').storage.size() < player.get_node('InventoryManager').max_storage_slots:
					picked_up.emit(self)
					_picked_up = true
					im.remove_child(self)
					player.get_node('InventoryManager').get_node('Items').add_child(self)
					get_child(0).get_child(0).visible = false
					get_child(0).get_child(1).visible = false
					get_child(1).visible = false
					return
				else:
					Utility.get_node("ErrorMessage")._create_error_message("Storage full", self)
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
		get_child(0).get_child(1).global_position = get_global_transform_with_canvas().get_origin() - Vector2(12, 0)
	
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
	get_child(0).get_child(0).global_position = get_viewport().get_mouse_position() - Vector2(get_child(0).get_child(0).size.x/2, -10)
	get_child(0).get_child(0).modulate.a = 1

	var viewport_size = get_viewport().size
	if get_child(0).get_child(0).global_position.x + get_child(0).get_child(0).size.x > viewport_size.x:
		get_child(0).get_child(0).global_position.x = viewport_size.x - get_child(0).get_child(0).size.x
	
	if get_child(0).get_child(0).global_position.y + get_child(0).get_child(0).size.y > viewport_size.y:
		get_child(0).get_child(0).global_position.y = viewport_size.y - get_child(0).get_child(0).size.y
	
func _get_item_data() -> Dictionary:
	var item_data = {
		"item_name": i_name,
		"rarity": rarity
	}
	return item_data


func _unhandled_input(event):
	if get_child(0).get_child(0).visible == false:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_panel.scroll_vertical -= 6
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_panel.scroll_vertical += 6
