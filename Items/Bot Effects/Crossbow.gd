extends Item
class_name Crossbow
var range : int = 125
var attack_damage : int = 7
var attack_speed : int = 30

var timer = 0
var additional_timer = 0
var cooldown = 15
var duration = 1.75
var duration_timer = 0

func _initialize():
	range = 125
	attack_damage = randi_range(3, 7)
	attack_speed = 15
	icon = preload('res://Sprites/Icons/Crossbow.png')
	type = ["Offense"]
	# Types: Defense, Utility, Offense, All
	weapon_tooltip = "\n[color=green]✸ [/color]Weapon Effect: Basic attack the closest enemy every 0.25 seconds for "+ str(duration) +" second(s), dealing 60% reduced direct damage, has a " + str(cooldown) + " second cooldown."

func _use_weapon(player, delta):
	timer += delta
	additional_timer += delta
	duration_timer += delta

	if is_using:
		if duration_timer >= duration:
			is_using = false
		if additional_timer >= 0.25:
			additional_timer = 0
			player.get_node('Control').attack_target = _find_closest_enemy(player)
			if player.get_node('Control').attack_target:
				player.get_node('Control')._attack([], [], 0.0, (get_global_mouse_position() - player.global_position).normalized(), 60)

func _find_closest_enemy(player):
	var closest_enemy = null
	var closest_distance = 9999
	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy

func _initialize_weapon(player):
	if timer >= cooldown:
		timer = 0
		is_using = true
		duration_timer = 0
	else:
		Utility.get_node('ErrorMessage')._create_error_message('Weapon effect is on cooldown.', player)

func _get_values():
	return [range, attack_damage, attack_speed]

func _get_tags():
	return ["range", "attack_damage", "attack_speed"]
