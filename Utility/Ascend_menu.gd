extends Panel
var player
var first_wave_stats = {}
var last_wave_stats = {}

func _on_ascend_pressed():
	var player = get_tree().get_nodes_in_group("players")[0]
	player.power += _calculate_ascend_power(first_wave_stats, last_wave_stats)
	player.item_drop_chance_multiplier += 0.2
	player.ascension_level += 1
	player._reset_completed_waves()
	get_tree().get_root().get_node('Main').get_child(0).get_node('WaveManager').players.append(player)
	get_tree().get_root().get_node('Main').get_child(0).get_node('AbilityManager')._on_next_curse()
	visible = false

func _calculate_ascend_power(first_wave, last_wave):
	var ascension_health = calculate_multiplier(first_wave['health'], last_wave['health'])
	var ascension_armor = calculate_multiplier(first_wave['armor'], last_wave['armor'])
	var ascension_damage = calculate_multiplier(first_wave['damage'], last_wave['damage'])

	return (ascension_health + ascension_armor + ascension_damage) / 3

func calculate_multiplier(first_wave_stat, last_wave_stat):
	return last_wave_stat / first_wave_stat

func _on_ascend(first, last):
	first_wave_stats = first
	last_wave_stats = last

func _on_return_pressed():
	GameManager._change_scene('res://Scenes/Menu.tscn', true)
