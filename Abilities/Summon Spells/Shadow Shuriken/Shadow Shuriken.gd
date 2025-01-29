extends Area2D
var target : Node
var origin : Node
var target_position : Vector2
var tag = null
var direction : Vector2
var moving = false
var hit_enemies = []

@export var cast_duration : float
@export var cooldown : float = 2.0
@export var reduced_cooldown : float = 0.0
@export var size : float
@export var tags : Array = ["Damage"]
@export var values : Array = [0.0]
@export var _range : float
@export var speed : float

func _get_closest_target():
	var distance_to_target = 99999999
	if origin.get_tree().get_nodes_in_group('enemies'):
		for child in origin.get_tree().get_nodes_in_group('enemies'):
			var distance = origin.global_position.distance_to(child.global_position)
			
			if distance < distance_to_target:
				distance_to_target = distance
				return child

func _process(delta):
	if !is_instance_valid(origin):
		queue_free()
		return
	if moving:
		_check_collision()
		self.global_position += direction * speed * delta
		if origin.global_position.distance_to(self.global_position) > _range:
			moving = false
			queue_free()

func _initialize_ability(unit):
	origin = unit
	target = _get_closest_target()
	target_position = target.global_position
	direction = (target_position - origin.global_position).normalized()
	self.global_position = origin.global_position

func _do_action(enemy):
	var extra = {"ability": "Shadow Shuriken"}
	origin.do_action.emit(10 + origin.get_tree().get_first_node_in_group("players").total_dexterity, enemy, origin, "Damage", extra)

func _check_collision():
	var overlapping = self.get_overlapping_areas()
	for area in overlapping:
		if area.is_in_group("enemies"):
			if not hit_enemies.has(area):
				hit_enemies.append(area)
				_do_action(area)

func _use():
	moving = true
