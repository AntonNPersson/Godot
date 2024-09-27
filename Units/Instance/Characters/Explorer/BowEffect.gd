extends Area2D
var is_active = false
var start_position
var new_target

var distance = 600
var direction = Vector2(0,0)
var speed = 450

var hit_enemies = []
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_active:
		var _rotation = direction.angle()
		self.rotation = _rotation
		self.global_position += direction * speed * delta
		if self.start_position.distance_to(new_target) < 10:
			queue_free()
		_check_collision()

func _start(target_position, player):
	global_position = player.global_position
	start_position = player.global_position
	direction = global_position.direction_to(target_position)
	new_target = start_position + global_position.direction_to(target_position) * distance
	self.player = player
	is_active = true

func _check_collision():
	var overlapping = self.get_overlapping_areas()

	for area in overlapping:
		if area.is_in_group('enemies') and area not in hit_enemies:
			hit_enemies.append(area)
			var crit = player._apply_critical_damage(player.total_attack_damage)
			var extra = {"basic_attacking": true, "critical" : crit["critical"]}
			var new_damage = crit["value"]
			player.get_node('Control')._on_action(new_damage, area, player, "Damage", extra)
			GameManager._shake_camera(player, 50, 0.2)
			player.get_node('Control')._on_action(45, area, player, "Wind")
			
