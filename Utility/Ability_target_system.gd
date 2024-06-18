extends Node2D
var origin
var target
var sized
var rangee
enum Type {
	Line,
	Target,
	Area,
	None
}

var current_type = Type.None

func _draw():
	if current_type == Type.Line:
		draw_line(origin.get_global_transform_with_canvas().get_origin(), get_local_mouse_position(), Color.GREEN, 10)
		draw_circle(get_local_mouse_position(), sized, Color.GREEN)
	elif current_type == Type.Target:
		draw_circle(get_local_mouse_position(), 20, Color.GREEN)
	elif current_type == Type.None:
		pass
	elif current_type == Type.Area:
		if rangee > 1000:
			return
		if rangee > 0:
			draw_circle(get_local_mouse_position(), sized, Color.GREEN)
		else:
			draw_circle(origin.get_global_transform_with_canvas().get_origin(), sized, Color.GREEN)
	
func _draw_line_targeting(unit, scaled):
	self.origin = unit
	sized = scaled
	current_type = Type.Line
	queue_redraw()
	
func _draw_area_targeting(radius, _range, _origin):
	current_type = Type.Area
	sized = radius
	rangee = _range
	origin = _origin
	queue_redraw()
	
func _draw_target_targeting():
	current_type = Type.Target
	queue_redraw()
	
func _erase_targeting():
	current_type = Type.None
	queue_redraw()
