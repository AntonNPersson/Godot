extends Node
var ascension_currency = 0

func _set_balance(value):
	ascension_currency = value

func _get_balance():
	return ascension_currency

func _add_balance(value):
	ascension_currency += value

func _remove_balance(value):
	ascension_currency -= value

func _reset_balance():
	ascension_currency = 0
