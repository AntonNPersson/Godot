extends Item
class_name Swiftening
var attack_speed = 10

func _initialize():
	attack_speed = attack_speed % 12 + 6

func _get_values():
	return [attack_speed]	

func _get_tags():
	return ["attack_speed"]