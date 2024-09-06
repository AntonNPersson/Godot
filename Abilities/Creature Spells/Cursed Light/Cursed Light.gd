extends Area2D
var target : Node
var origin : Node
var target_position : Vector2
var tag = "Damage"
var direction : Vector2
var hit_enemies = []

var reset_timer = 0.0
var current_bounce = 0
const MAX_BOUNCES = 3

@export var cast_duration : float
@export var cooldown : float = 2.0
@export var _range : float
@export var speed : float
@export var damage : float
signal do_damage(damage, target, this, tag)

func _calculate_new_direction():
	var angle = randf_range(0, 2 * PI)
	var _direction = Vector2(cos(angle), sin(angle))
	return _direction

func random_position_in_radius(center: Vector2, radius: float) -> Vector2:
	var angle = randf_range(0, 2 * PI)
	var x = cos(angle) * radius
	var y = sin(angle) * radius
	return center + Vector2(x, y)

func _use():
	await get_tree().create_timer(cast_duration).timeout
	direction = _calculate_new_direction()

func _process(delta):
	if origin == null or !is_instance_valid(origin):
		queue_free()
		return
	global_position += direction * speed * delta

	if hit_enemies.size() > 0:
		reset_timer += delta
		if reset_timer >= 0.2:
			hit_enemies = []
			reset_timer = 0.0

	if origin.current_health <= 0:
		queue_free()

func _on_area_entered(area:Area2D):
	if area.is_in_group('players') and area not in hit_enemies:
		hit_enemies.append(area)
		do_damage.emit(damage, area, self, tag)
	if area.is_in_group('player_summon'):
		hit_enemies.append(area)
		do_damage.emit(damage, area, self, tag)
	if area.is_in_group('obstacles'):
		var normal = (area.global_position - global_position).normalized()
		if abs(normal.x) > abs(normal.y):
			direction.x = -direction.x
		else:
			direction.y = -direction.y
