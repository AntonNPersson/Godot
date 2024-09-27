extends Item
class_name Bow
var range : int = 200
var attack_damage : int = 15

var timer = 0
var channel_timer = 0
var cooldown = 10
var channel_time = 1

func _initialize():
	range = 200
	attack_damage = randi_range(15, 25)
	icon = preload('res://Sprites/Icons/Bow.png')
	type = ["Offense"]
	# Types: Defense, Utility, Offense, All
	weapon_tooltip = "\n[color=green]✸ [/color]Weapon Effect: Channel for " + str(channel_time) + " second(s) and shoot an arrow towards the closest enemy to the mouse that knocks back enemies, has a " + str(cooldown) + " second cooldown."


func _get_values():
	return [range, attack_damage]

func _get_tags():
	return ["range", "attack_damage"]

func _use_weapon(player, delta):
	timer += delta

	if is_using:
		channel_timer += delta
		print(channel_timer)
		player.get_node('Control').attack_bar.visible = true
		player.get_node('Control').attack_bar.value = (channel_timer / channel_time) * 100
		player.get_node('Control').attack_bar.modulate = Color.GRAY

func _pre_initialize_weapon(player):
	if timer >= cooldown:
		is_using = true
		player.get_node('Control').movement_penalty = 0.5
	else:
		Utility.get_node('ErrorMessage')._create_error_message('Weapon effect is on cooldown.', player)

func _initialize_weapon(player):
	is_using = false
	player.get_node('Control').movement_penalty = 1
	if channel_timer >= channel_time:
			var new_effect = player.get_node('Extra').get_node('BowEffect').duplicate()
			new_effect._start(player.get_global_mouse_position(), player)
			new_effect.visible = true
			player.get_tree().get_root().add_child(new_effect)
			timer = 0
			player.get_node('Control').update_sprite_direction(player.global_position.direction_to(player.get_global_mouse_position()), "Attack")
	player.get_node('Control').attack_bar.visible = false
	channel_timer = 0
