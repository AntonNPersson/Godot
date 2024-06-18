extends Camera2D

# Camera movement speed
const MOVEMENT_SPEED = 1000

# Mouse drag sensitivity
const DRAG_SENSITIVITY = 0.5

# Screen edge threshold for camera movement
const EDGE_THRESHOLD = 50

const MIN_ZOOM = Vector2(0.1, 0.1)
const MAX_ZOOM = Vector2(4, 4)
const ZOOM_SPEED = Vector2(0.1, 0.1)

var is_dragging = false

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = true
		elif !event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = clamp(zoom - ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = clamp(zoom + ZOOM_SPEED, MIN_ZOOM, MAX_ZOOM)
	elif event is InputEventMouseMotion:
		if is_dragging:
			# Get mouse motion delta
			var delta = event.relative

			# Adjust the delta based on drag sensitivity
			delta *= DRAG_SENSITIVITY

			# Move the camera
			position -= delta * zoom

func _process(delta):
	# Check mouse position for camera movement
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport_rect().size

	if mouse_pos.x < EDGE_THRESHOLD:
		position.x -= MOVEMENT_SPEED * delta
	elif mouse_pos.x > screen_size.x - EDGE_THRESHOLD:
		position.x += MOVEMENT_SPEED * delta

	if mouse_pos.y < EDGE_THRESHOLD:
		position.y -= MOVEMENT_SPEED * delta
	elif mouse_pos.y > screen_size.y - EDGE_THRESHOLD:
		position.y += MOVEMENT_SPEED * delta

