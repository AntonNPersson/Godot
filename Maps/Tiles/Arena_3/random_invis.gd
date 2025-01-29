extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = randi() % 2 == 0