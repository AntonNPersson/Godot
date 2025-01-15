extends RichTextLabel

var velocity = Vector2()
var speed = 10
var time_passed = 0
var start = false
var target1
var _color
var scale_factor

var positive_effects = ["green", "blue", "purple"]

func _create_text(value, target, color):
	if !is_instance_valid(target):
		return
	text = '[center][color=' + color + ']' + str(snapped(value, 0.1)) + '[/color][/center]'
	_color = color
	target1 = target
	target.get_tree().current_scene.get_node('Combat Layer').add_child(self)
	global_position = target.global_position
	modulate = Color(1, 1, 1, 1)

	scale_factor = 0.45 + min(value / 1000.0, 1.0)
	scale_factor = clamp(scale_factor, 0.2, 1.0)
	scale = Vector2(scale_factor, scale_factor)
	if color == "Purple":
		text = '[center][color=Violet]' + str(snapped(value/2, 0.1)) + "(" + str(snapped(value/2, 0.1)) + ")" + '[/color][/center]'
	elif color == "Execute":
		text = '[center][color=Red]Executed[/color][/center]'
	if positive_effects.find(color) != -1:
		global_position.x -= 32
	start = true


func _update_text(value):
	text = '[center][color=' + _color + ']' + str(snapped(value, 0.1)) + '[/color][/center]'
	var scale_factor = 0.45 + min(value / 1000.0, 1.0)
	scale_factor = clamp(scale_factor, 0.2, 1.0)
	scale = Vector2(scale_factor, scale_factor)
	
func _process(delta):
	if start:
		time_passed += delta
		#global_position.y -= speed * delta
		
		# Apply horizontal sway using a sine wave
		if _color == "Purple":
			global_position.y -= speed * delta
		elif positive_effects.find(_color) != -1:
			global_position.x -= sin(time_passed * 6) * 15 * delta
			global_position.y -= speed * delta
		else:
			global_position.x += sin(time_passed * 6) * 15 * delta
			global_position.y -= speed * delta
		var t = 0.8 + (scale_factor - 0.8) * (time_passed / 1.0)
		if t < 0.8:
			t = 0.8
		if t > scale_factor:
			t = scale_factor
		
		scale = Vector2(t, t)
		
		if time_passed >= 1.0:
			queue_free()

