extends Node
var _unit = null
# Called when the node enters the scene tree for the first time.
func _initialize(unit, draw):
	_unit = unit
	self.global_position = unit.global_position 
	if draw:
		self.visible = true
	else:
		self.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _unit != null and is_instance_valid(_unit):
		self.global_position = _unit.global_position
	else:
		self.visible = false
