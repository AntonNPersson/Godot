extends Node

var bonus_ascension_gain = 0.0
var bonus_xp_gain = 0.0
var bonus_drop_rate = 0.0

var bonus_ascension_price = 150
var bonus_xp_price = 50
var bonus_drop_rate_price = 100

var pre_chosen_abilities = []

func _add_bonus_ascension_gain(value):
	bonus_ascension_gain += value

func _add_bonus_xp_gain(value):
	bonus_xp_gain += value

func _add_bonus_drop_rate(value):
	bonus_drop_rate += value

func _add_pre_chosen_ability(value):
	pre_chosen_abilities.append(value)

func _get_bonus_ascension_gain():
	return bonus_ascension_gain

func _get_bonus_xp_gain():
	return bonus_xp_gain

func _get_bonus_drop_rate():
	return bonus_drop_rate

func _get_pre_chosen_abilities():
	return pre_chosen_abilities

func _get_bonus_ascension_price():
	return bonus_ascension_price

func _get_bonus_xp_price():
	return bonus_xp_price

func _get_bonus_drop_rate_price():
	return bonus_drop_rate_price

func _set_bonus_ascension_price():
	if bonus_ascension_gain == 0.0:
		bonus_ascension_price = 150
	else:
		bonus_ascension_price = 150 * (bonus_ascension_gain/0.2)

func _set_bonus_xp_price():
	if bonus_xp_gain == 0.0:
		bonus_xp_price = 50
	else:
		bonus_xp_price = 50 * (bonus_xp_gain/0.2)

func _set_bonus_drop_rate_price():
	if bonus_drop_rate == 0.0:
		bonus_drop_rate_price = 100
	else:
		bonus_drop_rate_price = 100 * (bonus_drop_rate/0.2)

func _set_bonus_ascension_gain(value):
	bonus_ascension_gain = value

func _set_bonus_xp_gain(value):
	bonus_xp_gain = value

func _set_bonus_drop_rate(value):
	bonus_drop_rate = value

func _reset():
	bonus_ascension_gain = 0.0
	bonus_xp_gain = 0.0
	bonus_drop_rate = 0.0
	pre_chosen_abilities = []
