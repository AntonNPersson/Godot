extends PointLight2D

var base_intensity : float = 1.0
var intensity_variation : float = 0.2  # Adjust to control intensity flickering
var base_size : float = 1.5
var size_variation : float = 0.1  # Adjust to control size flickering

var flicker_timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	base_size = texture_scale
	flicker_timer = Timer.new()
	add_child(flicker_timer)
	flicker_timer.wait_time = 0.1  # Adjust the wait time for flickering
	flicker_timer.timeout.connect(_on_flicker_timeout)
	flicker_timer.start()

func _on_flicker_timeout():
	# Randomly adjust the intensity and size
	var random_intensity = randf_range(-intensity_variation, intensity_variation) * 0.5
	var random_size = randf_range(-size_variation, size_variation) * 0.5

	var flickering_intensity = base_intensity + random_intensity
	var flickering_size = base_size + random_size
	
	# Set the light intensity and size
	energy = flickering_intensity
	texture_scale = flickering_size

	# Restart the timer
	flicker_timer.start()

func _get_special():
	pass
