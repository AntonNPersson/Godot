extends Area2D
var running = false
var speed = 100
var direction = Vector2.ZERO
var tags = []
var values = []

func _initialize(speed, direction, tags, values):
	self.speed = speed
	self.direction = direction
	self.tags = tags
	self.values = values
	running = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if running:
		global_position += direction * speed * delta
		_check_collision()

func _check_collision():
	var colliders = get_overlapping_areas()
	for collider in colliders:
		if tags.size() > 0 and collider.is_in_group('players'):
			print(collider)
			for i in range(0, tags.size()):
				collider.get_node('Control').on_action.emit(values[i], collider, self, tags[i])
				queue_free()
