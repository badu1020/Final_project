extends Control


var ship_power = ConfigHandler.load_ship_size()
var invSize = 3
var ItemsLoad = [
	"res://Items/Cannons.tres",
	"res://Items/Lasers.tres",
	"res://Items/Railgun.tres"
	
]

var ship_size
var port2
var starbord2
var keel

func _ready() -> void:
	ship_size = ConfigHandler.load_ship_size()
	port2 = $Port2
	starbord2 = $Starbord2
	keel = $Keel
	
	_initialize_gui()
	for i in invSize:
		var slot = Inventory_slot.new()
		slot.init(ItemData.Type.STORAGE, Vector2(64,64))
		$weapons.add_child(slot)


	for i in ItemsLoad.size():
		var item = Inventory_item.new()
		item.init(load(ItemsLoad[i]))
		$weapons.get_child(i).add_child(item)
		
func _initialize_gui():
	match ship_size:
		0:
			keel.hide()
			port2.hide()
			starbord2.hide()
		1:
			port2.hide()
			starbord2.hide()
		2:
			pass
		_:
			pass
	
func refresh():
	_initialize_gui()

func _on_port_child_entered_tree(child: Node) -> void:
	ConfigHandler.save_weapons( child.data.weapon_id, "port")


func _on_port_2_child_entered_tree(child: Node) -> void:
	ConfigHandler.save_weapons( child.data.weapon_id, "post2")


func _on_starbord_child_entered_tree(child: Node) -> void:
	ConfigHandler.save_weapons( child.data.weapon_id, "starbord")


func _on_starbord_2_child_entered_tree(child: Node) -> void:
	ConfigHandler.save_weapons( child.data.weapon_id, "starbord2")


func _on_keel_child_entered_tree(child: Node) -> void:
	ConfigHandler.save_weapons( child.data.weapon_id, "keel")
