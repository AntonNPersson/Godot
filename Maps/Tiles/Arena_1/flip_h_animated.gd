extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	flip_h = randi() % 2 == 0