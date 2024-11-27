extends Item
class_name Sword
var range : int = 25
var attack_damage : int = 12
var attack_speed : int = 10

var timer = 0
var cooldown = 6

var attack_sprite = null

func _initialize():
	range = 25
	attack_damage = randi_range(12, 22)
	attack_speed = 10
	icon = preload('res://Sprites/Icons/Sword.png')
	type = ["Offense"]
	# Types: Defense, Utility, Offense, All
	weapon_tooltip = "\n[color=green]✸ [/color]Weapon Effect: Basic attack all enemies in range, has a " + str(cooldown) + " second cooldown."

func _use_weapon(player, delta):
	timer += delta

func _initialize_weapon(player):
	if timer >= cooldown:
		timer = 0
		for enemy in player.get_tree().get_nodes_in_group("enemies"):
			if player.global_position.distance_to(enemy.global_position) < player.total_range:
				var crit = player._apply_critical_damage(player.total_attack_damage)
				var new_damage = crit["value"]
				var extra = {"basic_attacking": true, "critical" : crit["critical"] , "ability" : null}
				GameManager._shake_camera(player, 100, 0.2)
				player.get_node('Control')._on_action(new_damage, enemy, player, "Damage", extra)
				for i in range(player.current_attack_modifier_tags.size()):
					extra = {"basic_attacking": true, "critical" : crit["critical"], "ability" : player.current_attack_modifier_abilities[i]}
					player.get_node('Control')._on_action(player.current_attack_modifier_values[i], enemy, player, player.current_attack_modifier_tags[i], extra)

		player.get_node('Control').update_sprite_direction(player.get_node('Control').movement_target, "Attack")
		
		if attack_sprite == null:
			attack_sprite = player.get_node('Control').attack_sprite.duplicate()
			player.get_node('Extra').add_child(attack_sprite)

		attack_sprite.get_child(0).play('default')
		attack_sprite.global_position = player.global_position
		attack_sprite.scale = Vector2(0.3, 0.3)
		attack_sprite.modulate = Color(0.6, 0.6, 1, 1)
	else:
		Utility.get_node('ErrorMessage')._create_error_message('Weapon effect is on cooldown.', player)
func _get_values():
	return [range, attack_damage, attack_speed]

func _get_tags():
	return ["range", "attack_damage", "attack_speed"]