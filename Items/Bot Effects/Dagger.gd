extends Item
class_name Dagger
var range : int = 15
var attack_damage : int = 8
var quick_attack_chance : int = 100

var target_location = Vector2()
var hit_targets = []
var duration = 0.2
var cooldown = 5
var timer = 0

var attack_sprite = null

func _initialize():
	range = 15
	attack_damage = randi_range(4, 6)
	quick_attack_chance = 100
	icon = preload('res://Sprites/Icons/Dagger.png')
	type = ["Offense"]
	# Types: Defense, Utility, Offense, All
	weapon_tooltip = "\n[color=green]✸ [/color]Weapon Effect: Quickly dash to the target location and basic attack all enemies in the path, has a " + str(cooldown) + " second cooldown."

func _use_weapon(player, delta):
	if !is_using or duration <= 0 or timer > 0:
		timer += delta
		return
	var areas = player.get_overlapping_areas()
	for a in areas:
			if a.is_in_group('obstacles'):
				duration = 0.2
				is_using = false
	if duration > 0:
		duration -= delta
	player.global_position += target_location.normalized() * 350 * delta
	player.get_node('Control').update_sprite_direction(target_location.normalized(), "Attack")
	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		if hit_targets.find(enemy) == -1 and player.global_position.distance_to(enemy.global_position) < 50:
			var crit = player._apply_critical_damage(player.total_attack_damage)
			var new_damage = crit["value"]
			var extra = {"basic_attacking": true, "critical" : crit["critical"]}
			GameManager._shake_camera(player, 50, 0.2)
			player.get_node('Control')._on_action(new_damage, enemy, player, "Damage", extra)
			for i in range(player.current_attack_modifier_tags.size()):
				player.get_node('Control')._on_action(player.current_attack_modifier_values[i], enemy, player, player.current_attack_modifier_tags[i])
			hit_targets.append(enemy)

func _initialize_weapon(player):
	if timer >= cooldown:
		timer = 0
		var direction = get_global_mouse_position() - player.global_position
		target_location = direction.normalized() * 50
		print(target_location)
		is_using = true
		duration = 0.2
		hit_targets = []

		if attack_sprite == null:
			attack_sprite = player.get_node('Control').attack_sprite.duplicate()
			player.get_node('Extra').add_child(attack_sprite)

		attack_sprite.get_child(0).play('default')
		attack_sprite.rotation = target_location.angle()
		attack_sprite.global_position = player.global_position + (target_location - player.global_position).normalized()
		attack_sprite.scale = Vector2(0.35, 0.06)
		attack_sprite.modulate = Color(0.6, 1, 0.6, 1)
	else:
		Utility.get_node('ErrorMessage')._create_error_message('Weapon effect is on cooldown.', player)

func _change_weapon_cooldown(value):
	cooldown = value

func _get_values():
	return [range, attack_damage, quick_attack_chance]

func _get_tags():
	return ["range", "attack_damage", "quick_attack_chance"]