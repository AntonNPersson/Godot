extends Node2D
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

var cooldown : float
var tags : Array
var values : Array
var speed : float

var special = false
var player = null
var map = null
var timer = 0

var ascension_currency_multiplier = 0.6

var second_tooltip

func _ready():
	second_tooltip = "Stormy winds fly from random directions every 2 seconds, pushing you back."

func _start_special(players, maps):
	cooldown = 2.0
	speed = 300
	tags = ["Wind"]
	values = [100.0]
	player = players
	map = maps
	timer = 0
	special = true

func _stop_special():
	special = false

func _update_special(delta):
	if special:
		timer += delta
		if timer >= cooldown:
			timer = 0
			_use()

func _use():
	var wind_obj = get_node('Wind').duplicate()

	var viewport_size = get_viewport_rect().size
	var padding = 300  # Safe margin from the edges to prevent shooting offscreen
	var side = randi() % 4
	var start_position: Vector2
	var target_position: Vector2

	# Get player's position
	var player_position = player.global_position

	match side:
		0:  # Left side
			start_position = Vector2(0, randf() * viewport_size.y)  # Random Y along the left edge
			target_position = Vector2(viewport_size.x, clamp(randf() * viewport_size.y, padding, viewport_size.y - padding))  # Random Y on the right edge with padding
		1:  # Right side
			start_position = Vector2(viewport_size.x, randf() * viewport_size.y)  # Random Y along the right edge
			target_position = Vector2(0, clamp(randf() * viewport_size.y, padding, viewport_size.y - padding))  # Random Y on the left edge with padding
		2:  # Top side
			start_position = Vector2(randf() * viewport_size.x, 0)  # Random X along the top edge
			target_position = Vector2(clamp(randf() * viewport_size.x, padding, viewport_size.x - padding), viewport_size.y)  # Random X on the bottom edge with padding
		3:  # Bottom side
			start_position = Vector2(randf() * viewport_size.x, viewport_size.y)  # Random X along the bottom edge
			target_position = Vector2(clamp(randf() * viewport_size.x, padding, viewport_size.x - padding), 0)  # Random X on the top edge with padding

	# Adjust the target_position slightly towards the player
	var adjustment_strength = 0.8  # Value between 0 (no adjustment) and 1 (fully towards player)
	target_position = target_position.lerp(player_position, adjustment_strength)

	# Set wind object's initial position and direction
	wind_obj.global_position = start_position
	var direction = (target_position - start_position).normalized()

	# Add offset to rotation
	var offset = PI / 2  # 90-degree offset if required for correct orientation
	wind_obj.scale = Vector2(2, 2)
	wind_obj.rotation = direction.angle() + offset

	# Initialize wind object
	wind_obj._initialize(speed, direction, tags, values)
	wind_obj.visible = true

	# Add wind object to the scene
	get_tree().get_root().get_node('Main').get_node('Objects').add_child(wind_obj)



