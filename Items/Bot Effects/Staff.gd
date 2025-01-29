extends Item
class_name Staff
var strength : int = 0
var dexterity : int = 0
var intelligence : int = 0
var range : int = 175
var attack_damage : int = 3

var timer = 0
var duration = 3
var cooldown = 10

func _initialize():
	attack_damage = randi_range(1, 3)
	var attribute = _adjust_attributes()
	match attribute:
		0:
			strength = randi_range(10, 15)
		1:
			dexterity = randi_range(10, 15)
		2:
			intelligence = randi_range(10, 15)
	range = 175
	icon = preload('res://Sprites/Icons/Staff.png')
	type = ["Offense"]
	# Types: Defense, Utility, Offense, All
	weapon_tooltip = "\n[color=green]✸ [/color]Weapon Effect: Boost mana regeneration by 500% and movement speed by 35% for " + str(duration) + " second(s), has a " + str(cooldown) + " second cooldown."

func _use_weapon(player, delta):
	timer += delta

func _initialize_weapon(player):
	if timer >= cooldown:
		timer = 0
		player.get_node('Control')._on_action(500, duration, player, "BoostManaRegenPercent")
		player.get_node('Control')._on_action(35, player, duration, "PercentSpeedBuff")
		player.get_node('Extra').get_node('StaffEffect').lifetime = duration
		player.get_node('Extra').get_node('StaffEffect').emitting = true
	else:
		Utility.get_node('ErrorMessage')._create_error_message('Weapon effect is on cooldown.', player)

func _get_values():
	return [intelligence, range, strength, dexterity, attack_damage]

func _get_tags():
	return ["intelligence", "range", "strength", "dexterity", "attack_damage"]

func _adjust_attributes():
	var ra = randi_range(0,2)
	return ra
