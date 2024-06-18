extends Node2D
var _name
var _special
var _tiles
@export var tile : Button
@export var set : Button
@export var title : Label
@export var back : Button

func _create_tileset():
	var node = get_node('Node2D')
	var fileDialog = get_node('Node').get_node('FileDialog')
	node.visible = true
	fileDialog.visible = true
	tile.visible = false
	set.visible = false
	title.visible = false
	back.visible = true

func _create_directory(name, special):
	_name = name
	_special = special
	var dir = DirAccess.open('res://Tool/Tilesets')
	dir.make_dir(name)
	
	var node = Node.new()
	node.name = _name
	node.set_meta('special', _special)

func _create_tile():
	var node = get_node('Node')
	var fileDialog = node.get_node('FileDialog')
	node.visible = true
	fileDialog.visible = true
	tile.visible = false
	set.visible = false
	title.visible = false
	back.visible = true

func _back_to_menu():
	var node = get_node('Node')
	var node2 = get_node('Node2D')
	var fileDialog = node.get_node('FileDialog')
	node.visible = false
	node2.visible = false
	fileDialog.visible = false
	tile.visible = true
	set.visible = true
	title.visible = true
	back.visible = false


func _on_FileDialog_file_selected(path):
	for p in path.size():
		var file = load(path[p])
		_tiles.append(file)
