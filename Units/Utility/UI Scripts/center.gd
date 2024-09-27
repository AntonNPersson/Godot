extends Label
var im
@export var left = false

# Called when the node enters the scene tree for the first time.
func _ready():
	im = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if left:
		global_position.x = im.get_node('ProgressBar2').global_position.x + size.x/4
	else:
		global_position.x = im.get_node('ProgressBar3').global_position.x + size.x/4
