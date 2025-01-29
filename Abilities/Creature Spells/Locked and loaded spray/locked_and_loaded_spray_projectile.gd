extends Area2D
var origin
var direction = Vector2(0,0)
@export var bonus_speed = 400
var _range = 1000
var tags = []
var values = [0.0]
signal do_damage(damage, target, this, tag)
var hit_enemies = []
var in_air = false
var is_hit = []

func _use():
	get_node('Sprite2D').play('air')
	in_air = true
	self.visible = true

func _on_hit_finished():
	queue_free()
	
func _physics_process(delta):
	_check_if_caster_died(origin)
	_check_collision()
	if in_air:
		self.global_position += direction * bonus_speed * delta
		self.rotation = direction.angle()

func _check_if_caster_died(_origin):
	if !is_instance_valid(_origin):
		queue_free()

func _check_collision():
	var overlapping = self.get_overlapping_areas()
	if origin.global_position.distance_to(self.global_position) > _range:
		get_node('Sprite2D').play('hit')
		if !get_node('Sprite2D').animation_finished.is_connected(_on_hit_finished):
			get_node('Sprite2D').animation_finished.connect(_on_hit_finished)
		return

	for area in overlapping:
		if area.is_in_group('players') or area.is_in_group('player_summon'):
			if is_hit.has(area):
				continue
			for tag in range(tags.size()):
				do_damage.emit(values[tag], area, self, tags[tag])
			get_node('Sprite2D').play('hit')
			is_hit.append(area)
			if !get_node('Sprite2D').animation_finished.is_connected(_on_hit_finished):
				get_node('Sprite2D').animation_finished.connect(_on_hit_finished)
			return
