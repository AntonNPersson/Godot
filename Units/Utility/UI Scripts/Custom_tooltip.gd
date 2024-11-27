extends ItemList

func _make_custom_tooltip(for_text):
	var tooltip = preload("res://Utility/Tooltip.tscn").instantiate()
	tooltip.get_child(0).get_child(0).text = "[center]" + for_text
	return tooltip