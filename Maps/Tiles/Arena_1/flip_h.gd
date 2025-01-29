extends Sprite2D

@export var slightly_randomize_position : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	flip_h = randi() % 2 == 0

	if slightly_randomize_position:
		var random_x = randi_range(-10, 10)
		var random_y = randi_range(-10, 10)
		global_position.x += random_x
		global_position.y += random_y
		if get_parent().has_node("CollisionShape2D"):
			get_parent().get_node("CollisionShape2D").global_position.x += random_x
			get_parent().get_node("CollisionShape2D").global_position.y += random_y
