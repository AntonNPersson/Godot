extends Node
var items_scene
var items
var selected_item
var selected_item_inventory
var shop_hud
var timer
var allowed = false
var buying_allowed = false
signal item_bought(item)
signal item_sold(item)
signal get_item()
signal shop_closed()

func _ready():
	
	items_scene = preload("res://Items/items.tscn")
	items = items_scene.instantiate()
	add_child(items)
	shop_hud = get_node('UI/Panel')
	for i in items.get_children():
		shop_hud.get_node('shopList').add_item(i.name)
		
func _input(event):
	if allowed:
		if event.is_action_released("Shop"):
			if GameManager.is_singleplayer:
				return
			if shop_hud.visible == true:
				shop_hud.visible = false
			else: 
				shop_hud.visible = true

func _buy_item():
	if buying_allowed:
		item_bought.emit(selected_item)
		
func _sell_item():
	if selected_item:
		get_item.emit()
		item_sold.emit(selected_item_inventory)
		selected_item_inventory = null
		
func _on_character_selected(unit):
	allowed = true
	item_bought.connect(unit.get_node("InventoryManager")._on_item_bought)
	item_sold.connect(unit.get_node("InventoryManager")._on_item_sold)
	get_item.connect(unit.get_node("InventoryManager")._on_get_item)
	unit.get_node("InventoryManager").item_selected.connect(_get_item)

func _on_item_selected(index):
	selected_item = items.get_children()[index]

func _on_buy_button_pressed():
	_buy_item()

func _on_next_shop(time):
	buying_allowed = true
	timer = Timer.new()
	timer.timeout.connect(_on_timer_timeout)
	timer.set_wait_time(time)
	add_child(timer)
	timer.start()
	
func _close_shop():
	shop_closed.emit()
	buying_allowed = false
	
func _on_timer_timeout():
	_close_shop()
	timer.stop()
	
func _on_sell_button_pressed():
	_sell_item()
	
func _get_item(item):
	selected_item_inventory = item
