extends RichTextLabel

var velocity = Vector2()
var speed = 20
var time_passed = 0
var start = false
var target1
var _color
var scale_factor

func _create_text(value, target, color):
	if !is_instance_valid(target):
		return
	text = '[center][color=' + color + ']' + str(snapped(value, 0.1)) + '[/color][/center]'
	_color = color
	target1 = target
	target.get_tree().current_scene.get_child(0).get_node('UI').add_child(self)
	global_position = target.get_global_transform_with_canvas().get_origin()

	scale_factor = 1.0 + min(value / 1000.0, 1.0)
	scale_factor = clamp(scale_factor, 0.2, 2.0)
	scale = Vector2(scale_factor, scale_factor)
	if color == "Purple":
		text = '[center][color=Violet]' + str(snapped(value/2, 0.1)) + "(" + str(snapped(value/2, 0.1)) + ")" + '[/color][/center]'
	start = true


func _update_text(value):
	text = '[center][color=' + _color + ']' + str(snapped(value, 0.1)) + '[/color][/center]'
	var scale_factor = 1.0 + min(value / 100.0, 1.0)
	scale_factor = clamp(scale_factor, 0.8, 10.0)
	scale = Vector2(scale_factor, scale_factor)
	
func _process(delta):
	if start:
		time_passed += delta
		#global_position.y -= speed * delta
		
		# Apply horizontal sway using a sine wave
		global_position.x += sin(time_passed * 5) * 15 * delta
		var t = 0.8 + (scale_factor - 0.8) * (time_passed / 0.7)
		if t < 0.8:
			t = 0.8
		if t > scale_factor:
			t = scale_factor
		
		scale = Vector2(t, t)
		
		if time_passed >= 0.7:
			queue_free()

