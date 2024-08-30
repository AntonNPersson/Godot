extends Node

@onready var follow_cam = get_child(0)
@onready var parent = get_parent()
var is_following = true

@export var cam_speed = 3000

@export var min_zoom = Vector2(2, 2)
@export var max_zoom = Vector2(4, 4)

@export var shake_duration = 0.0
var original_shake_duration = 0.0
@export var shake_intensity = 0.0
@export var shake_speed = 0.0

var is_shaking = false

func _ready():
	follow_cam.zoom = clamp(follow_cam.zoom - Vector2(0.01, 0.01), min_zoom, max_zoom)
	original_shake_duration = shake_duration

func cam_speed_set(value):
	cam_speed = value

func _input(event):
	if parent.paused or parent.lose_camera_focus:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			follow_cam.zoom = clamp(follow_cam.zoom - Vector2(0.01, 0.01), min_zoom, max_zoom)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			follow_cam.zoom = clamp(follow_cam.zoom + Vector2(0.01, 0.01), min_zoom, max_zoom)

func _toggle_follow():
	is_following = not is_following

func _process(delta):
	if parent.paused:
		return

	if is_shaking and GameManager.settings['screen_shake']:
		if shake_duration > 0:
			shake_duration -= delta
			var x = sin(shake_speed * shake_duration) * shake_intensity
			var y = cos(shake_speed * shake_duration) * shake_intensity
			follow_cam.global_position = follow_cam.global_position + Vector2(x, y)
		else:
			shake_duration = original_shake_duration
			is_shaking = false

	if Input.is_action_just_released("Following"):
		_toggle_follow()

	if is_following:
		var target_position = parent.global_position.round()
		follow_cam.global_position = follow_cam.global_position.lerp(target_position, 0.2)
	else:
		var mouse_pos = get_viewport().get_mouse_position()
		var screen = get_viewport().size
		var margin = 10

		if mouse_pos.x > screen.x - margin:
			follow_cam.global_position.x += cam_speed * delta
		elif mouse_pos.x < margin:
			follow_cam.global_position.x -= cam_speed * delta

		if mouse_pos.y > screen.y - margin:
			follow_cam.global_position.y += cam_speed * delta
		elif mouse_pos.y < margin:
			follow_cam.global_position.y -= cam_speed * delta
