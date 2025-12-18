@tool
extends Node
class_name Equipable

@export var slots := {
	"port": NodePath("Port"),
	"port2": NodePath("Port2"),
	"starbord": NodePath("Starbord"),
	"starbord2": NodePath("Starbord2"),
	"keel": NodePath("Keel")
}

func load_from_config() -> void:
	var weapon_ports := ConfigHandler.load_weapons()
	for port in weapon_ports:
		var weapon_id = weapon_ports[port]
		
		# Skip if no weapon selected (-1)
		if weapon_id == -1:
			continue
		
		var item = ItemDataBase.get_item(weapon_id)
		_apply_to_slot(port, item)

func _apply_to_slot(port: String, item: ItemData) -> void:
	var sprite := get_node(slots[port]) as Sprite2D
	
	# Additional safety check
	if item.texture == null:
		sprite.visible = false
		return
	
	sprite.texture = item.texture
	sprite.visible = true
