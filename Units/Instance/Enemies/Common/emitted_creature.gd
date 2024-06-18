extends Node
var unit
var spell

# Called when the node enters the scene tree for the first time.
func _ready():
	unit = get_parent()
	spell = unit.abilities[0].instantiate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
