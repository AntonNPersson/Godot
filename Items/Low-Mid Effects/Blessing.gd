extends Item
class_name Blessing
var increased_drop_chance = 10.0

func _initialize():
	increased_drop_chance = round_to_dec(randf_range(5.0, 15.0), 2)

func _get_values():
	return [increased_drop_chance]	

func _get_tags():
	return ["increased_drop_chance"]
