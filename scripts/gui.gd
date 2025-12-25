extends Control

var ship_power = ConfigHandler.load_ship_size()
var invSize = 3
var weapon_id : int

var ItemsLoad = [
	"res://Items/Cannons.tres",
	"res://Items/Lasers.tres",
	"res://Items/Railgun.tres"
]

var ship_size
var port2
var starbord2
var keel
var power_usage: int = 0

# TEMP loadout (saved only on Save)
var pending_weapons := {
	"port": -1,
	"port2": -1,
	"starbord": -1,
	"starbord2": -1,
	"keel": -1
}

@onready var text_screen = $RichTextLabel2

func _ready() -> void:
	ship_size = ConfigHandler.load_ship_size()

	port2 = $Port2
	starbord2 = $Starbord2
	keel = $Keel

	_initialize_gui()

	# Create inventory slots
	for i in invSize:
		var slot = Inventory_slot.new()
		slot.init(ItemData.Type.STORAGE, Vector2(64, 64))
		$weapons.add_child(slot)

	# Load items into inventory
	for i in ItemsLoad.size():
		var item = Inventory_item.new()
		item.init(load(ItemsLoad[i]))
		$weapons.get_child(i).add_child(item)

# -------------------------------------------------
# GUI
# -------------------------------------------------

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

func refresh():
	_initialize_gui()

# -------------------------------------------------
# SLOT HANDLERS (NO SAVING HERE)
# -------------------------------------------------

func _on_port_child_entered_tree(child: Node) -> void:
	_assign_weapon(child, "port")

func _on_port_2_child_entered_tree(child: Node) -> void:
	_assign_weapon(child, "port2")

func _on_starbord_child_entered_tree(child: Node) -> void:
	_assign_weapon(child, "starbord")

func _on_starbord_2_child_entered_tree(child: Node) -> void:
	_assign_weapon(child, "starbord2")

func _on_keel_child_entered_tree(child: Node) -> void:
	_assign_weapon(child, "keel")

func _assign_weapon(child: Node, slot_key: String) -> void:
	weapon_id = child.data.weapon_id
	pending_weapons[slot_key] = weapon_id
	total_power(child.data.power)

# -------------------------------------------------
# POWER LIMIT
# -------------------------------------------------

func total_power(power: int) -> void:
	power_usage += power

	var limit := 0
	match ship_size:
		0: limit = 4
		1: limit = 7
		2: limit = 10

	if power_usage > limit:
		get_tree().paused = true
		text_screen.show()
	else:
		get_tree().paused = false
		text_screen.hide()

# -------------------------------------------------
# CLEAR
# -------------------------------------------------

func _clear_slot(slot: Node) -> void:
	for child in slot.get_children():
		if child is Inventory_item:
			child.queue_free()

func _clear_inventory() -> void:
	for slot in $weapons.get_children():
		for child in slot.get_children():
			if child is Inventory_item:
				child.queue_free()

func _on_clear_pressed() -> void:
	print("clear")
	_clear_slot($Port)
	_clear_slot($Port2)
	_clear_slot($Starbord)
	_clear_slot($Starbord2)
	_clear_slot($Keel)

	_clear_inventory()

	power_usage = 0
	get_tree().paused = false
	text_screen.hide()

	for key in pending_weapons.keys():
		pending_weapons[key] = -1

# -------------------------------------------------
# SAVE (ONLY PLACE THAT WRITES CONFIG)
# -------------------------------------------------

func _on_save_pressed() -> void:
	print("save")
	for slot in pending_weapons.keys():
		ConfigHandler.save_weapons(pending_weapons[slot], slot)

	print("Weapons saved:", pending_weapons)
