extends Item
class_name Scepter
var strength : int = 0
var dexterity : int = 0
var intelligence : int = 0
var range : int = 15
var attack_damage : int = 3
var increased_global_weight : int = -30

var timer = 0
var cooldown = 10
var duration = 1.75

func _initialize():
	var attribute = _adjust_attributes()
	match attribute:
		0:
			strength = randi_range(10, 20)
		1:
			dexterity = randi_range(10, 20)
		2:
			intelligence = randi_range(10, 20)
	range = 15
	increased_global_weight = -30
	attack_damage = randi_range(1, 2)
	icon = preload('res://Sprites/Icons/Scepter.png')
	type = ["Offense"]
	# Types: Defense, Utility, Offense, All
	weapon_tooltip = "\n[color=green]✸ [/color]Weapon Effect: Become invincible for " + str(duration) + " second(s) but rooting yourself, afterwards knock surrounding enemies back, has a " + str(cooldown) + " second cooldown."

func _use_weapon(player, delta):
	timer += delta

func _initialize_weapon(player):
	if timer >= cooldown:
		timer = 0
		player.is_rooted = true
		player.get_node('Control')._on_action(duration, player, player, "SelfInvincible")
		await get_tree().create_timer(duration).timeout
		player.is_rooted = false
		player.get_node('Extra').get_node('ScepterEffect').emitting = true
		GameManager._shake_camera(player, 100, 0.2)
		for enemy in player.get_tree().get_nodes_in_group("enemies"):
			if player.global_position.distance_to(enemy.global_position) < 70:
				player.get_node('Control')._on_action(30, enemy, player, "Wind")
	else:
		Utility.get_node('ErrorMessage')._create_error_message('Weapon effect is on cooldown.', player)


func _get_values():
	return [intelligence, range, strength, dexterity, increased_global_weight, attack_damage]

func _get_tags():
	return ["intelligence", "range", "strength", "dexterity", "increased_global_weight", "attack_damage"]

func _adjust_attributes():
	var ra = randi_range(0,2)
	return ra
