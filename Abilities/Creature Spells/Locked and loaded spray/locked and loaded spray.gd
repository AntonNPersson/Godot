extends Node
var origin : Node
var tag = null
var improved = false

@export var cast_duration : float
@export var cooldown : float = 2.0
@export var _range : float
@export var size : float
@export var tags : Array = ["Damage"]
@export var values : Array = [0.0]
@export var projectile_scene : PackedScene
@export var num_projectiles = 10
@export var delay_between_projectiles = 0.5
@export var radius = 50
signal do_damage(damage, target, this, tag, extra)
var angle_step = 360 / num_projectiles


func _use():
	get_child(0).global_position = origin.global_position
	get_child(0).play()
	origin.do_action.emit(-origin.total_speed, origin, cast_duration, 'SpeedBuff')
	await get_tree().create_timer(1).timeout
	for i in range(num_projectiles):
		var angle = deg_to_rad(i * angle_step)
		var direction = Vector2(cos(angle), sin(angle))

		var projectile = projectile_scene.instantiate()
		projectile.global_position = origin.global_position
		projectile.direction = direction
		projectile.origin = origin
		projectile.tags = tags
		projectile.values = values
		projectile.scale = Vector2(size, size)
		projectile._range = _range
		projectile.do_damage.connect(origin._on_do_action)
		origin.get_tree().get_root().get_node('Main').add_child(projectile)
		projectile._use()
		await get_tree().create_timer(delay_between_projectiles).timeout
	queue_free()

