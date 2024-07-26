extends TextureProgressBar
var abilities = []
var running = false
var cast_timer = 0
var duration = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	abilities = get_parent().get_parent().abilities

func _start(duration):
	if running:
		return false
	running = true
	value = 0
	self.duration = duration
	visible = true
	return true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if value >= 90:
		modulate = Color.RED
	if value >= 99:
		modulate = Color.WHITE

	if running:
		cast_timer += delta
		value = _calculate_cast_percentage()
		if cast_timer >= duration:
			cast_timer = 0
			value = 0
			running = false

func _calculate_cast_percentage():
	var perc = (cast_timer/duration) * 100
	return perc
