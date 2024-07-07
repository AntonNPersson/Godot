extends ItemList
@export var item_tooltip : PackedScene

func _make_custom_tooltip(for_text):
	var tooltip = item_tooltip.instantiate()
	var tooltip_name = tooltip.get_node("VSplitContainer/Name")
	var tooltip_main_desc = tooltip.get_node("VSplitContainer/Description")
	var tooltip_sub_desc = tooltip.get_node("VSplitContainer2/ScrollContainer/Description")
	var tooltip_icon = tooltip.get_node("Panel/Icon")
	var tooltip_icon_border = tooltip.get_node("Panel/Icon_border")

	var result = JSON.parse_string(for_text)
	
	var item_data = result
	tooltip_name.text = item_data["tooltip_name"]
	tooltip_main_desc.text = item_data["tooltip_main_desc"]
	tooltip_sub_desc.text = item_data["tooltip_sub_desc"]
	tooltip_icon.texture = load(item_data["tooltip_icon"])

	match item_data['rarity']:
		'Common':
			tooltip_name.modulate = Color.LAWN_GREEN
			tooltip_icon_border.modulate = Color.LAWN_GREEN
		'Uncommon':
			tooltip_name.modulate = Color.DODGER_BLUE
			tooltip_icon_border.modulate = Color.DODGER_BLUE
		'Rare':
			tooltip_name.modulate = Color.DARK_ORANGE
			tooltip_icon_border.modulate = Color.DARK_ORANGE
		'Epic':
			tooltip_name.modulate = Color.BLUE_VIOLET
			tooltip_icon_border.modulate = Color.BLUE_VIOLET
		'Legendary':
			tooltip_name.modulate = Color.GOLD
			tooltip_icon_border.modulate = Color.GOLD

	return tooltip
