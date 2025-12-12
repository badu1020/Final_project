extends TextureRect
class_name Inventory_item

@export var data: ItemData

func init(d: ItemData) -> void:
	data = d

func _ready() -> void:
	texture = data.texture
	tooltip_text = "%s\n%s" % [data.name, data.disc]
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	## Prevent the item from expanding the parent slot
	#size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	#size_flags_vertical = Control.SIZE_SHRINK_CENTER

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview := TextureRect.new()
	preview.texture = texture
	preview.modulate.a = 0.5
	preview.custom_minimum_size = size

	set_drag_preview(preview)

	return self   


func duplicate_item() -> Inventory_item:
	var new_item: Inventory_item = self.duplicate()
	new_item.data = data
	new_item.texture = data.texture
	return new_item


func make_drag_preview(at_position: Vector2) -> Control:
	var preview := TextureRect.new()
	preview.texture = texture
	preview.expand_mode = expand_mode
	preview.stretch_mode = stretch_mode
	preview.custom_minimum_size = size
	preview.modulate.a = 0.5
	preview.position = -at_position

	#var wrapper := Control.new()
	#wrapper.add_child(preview)
	return preview
