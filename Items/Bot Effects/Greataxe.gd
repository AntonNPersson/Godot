extends Item
class_name Greataxe
var range : int = 15
var attack_damage : int = 10
var attack_speed : int = -30
var attack_targets : int = 2

var timer = 0
var cooldown = 6

var target = null
var attack_sprite = null

func _initialize():
	range = 15
	attack_damage = randi_range(1, 3)
	attack_speed = -15
	attack_targets = 2
	icon = preload('res://Sprites/Icons/Greataxe.png')
	type = ["Offense"]
	# Types: Defense, Utility, Offense, All
	weapon_tooltip = "\n[color=green]✸ [/color]Weapon Effect: Charge towards target enemy and deal triple attack damage, has a " + str(cooldown) + " second cooldown."

func _get_values():
	return [range, attack_damage, attack_speed, attack_targets]

func _get_tags():
	return ["range", "attack_damage", "attack_speed", "attack_targets"]

func _use_weapon(player, delta):
	timer += delta
	if is_using:
		if player.global_position.distance_to(target.global_position) < range:
			player.get_node('Control').attack_target = _get_closest_visible_enemy_to_mouse()
			var crit = player._apply_critical_damage(player.total_attack_damage * 3)
			var extra = {"basic_attacking": true, "critical" : crit["critical"], "ability" : null}
			var new_damage = crit["value"]
			GameManager._shake_camera(player, 100, 0.2)
			player.get_node('Control')._on_action(new_damage, target, player, "Damage", extra)
			for i in range(player.current_attack_modifier_tags.size()):
				extra = {"basic_attacking": true, "critical" : crit["critical"], "ability" : player.current_attack_modifier_abilities[i]}
				player.get_node('Control')._on_action(player.current_attack_modifier_values[i], target, player, player.current_attack_modifier_tags[i], extra)
			player.get_node('Control').update_sprite_direction(player.global_position.direction_to(target.global_position), "Attack")
			player.get_node('Extra').get_node('GreataxeEffect').emitting = false
			
			if attack_sprite == null:
				attack_sprite = player.get_node('Control').attack_sprite.duplicate()
				player.get_node('Extra').add_child(attack_sprite)

			attack_sprite.get_child(0).play('default')
			attack_sprite.global_position = player.global_position + 20 * player.global_position.direction_to(target.global_position)
			attack_sprite.scale = Vector2(0.1, 0.1)
			attack_sprite.modulate = Color(1, 0.0, 0.0, 1)
			attack_sprite.rotation = player.global_position.direction_to(target.global_position).angle()
			is_using = false
		else:
			player.global_position += player.global_position.direction_to(target.global_position) * 450 * delta
			player.get_node('Extra').get_node('GreataxeEffect').emitting = true
			player.get_node('Extra').get_node('GreataxeEffect').rotation = player.global_position.direction_to(target.global_position).angle()
			player.get_node('Control').update_sprite_direction(player.global_position.direction_to(target.global_position), "Walk")

func _initialize_weapon(player):
	target = _get_closest_visible_enemy_to_mouse()
	if timer >= cooldown and target != null:
		timer = 0
		is_using = true
	else:
		Utility.get_node('ErrorMessage')._create_error_message('Weapon effect is on cooldown.', player)