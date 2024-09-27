extends Item
class_name Ascension
var increased_anscension_currency = 10

func _initialize():
	increased_anscension_currency = increased_anscension_currency % 8 + 3

func _get_values():
	return [increased_anscension_currency]	

func _get_tags():
	return ["increased_anscension_currency"]