class_name ImageWidget
extends Widget

const scene = preload("res://core/widgets/entities/visual/image_widget.tscn")

@export var entity: ImageEntity
var image: TextureRect
var tween: Tween

func init(properties: Dictionary) -> void:
	var data
	print(entity.image_path)
	if zip_file != null:
		if !zip_file.file_exists(entity.image_path):
			push_error("Image file not found: " + entity.image_path)
			return
		data = zip_file.read_file(entity.image_path)
	
	else:
		var relative_path: String = entity.image_path
		var image_disk_path: String = dir_class.path_join(relative_path)
		if not FileAccess.file_exists(image_disk_path):
			push_error("Image file not found: " + image_disk_path)
			return
		var f := FileAccess.open(image_disk_path, FileAccess.READ)
		if f == null:
			push_error("No se pudo abrir: " + image_disk_path)
			return
		data = f.get_buffer(f.get_length())
		f.close()

	var texture := _create_texture(data)
	image = scene.instantiate()
	image.stretch_mode = TextureRect.STRETCH_SCALE 
	add_child(image)
	if properties.has("position"):
		position = properties["position"]
	if properties.has("size"):
		image.size = properties["size"]
	image.texture = texture
	
	if class_node is ClassLeaf:
		(class_node as ClassLeaf).property_updated.connect(_on_property_updated)

func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	#image.modulate = Color(1,1,1,0)
	image.show()
	#tween = create_tween()
	#tween.tween_property(image, "modulate", Color(1, 1, 1, 1), entity.duration)
	_bus_core.current_node_changed.emit(class_node)

	add_to_group(&"playing_widget")
	remove_from_group(&"widget_playing")
	add_to_group(&"widget_finished")
	emit_signal("widget_finished")

func reset():
	if tween:
		tween.kill()
	image.hide()
	remove_from_group(&"widget_playing")
	remove_from_group(&"widget_finished")
	emit_signal("widget_finished")

func stop() -> void:
	skip_to_end()

func skip_to_end() -> void:
	if tween:
		tween.kill()
	image.show()
	# image.modulate = Color(1, 1, 1, 1)
	add_to_group(&"widget_finished")
	emit_signal("widget_finished")


func clear():
	reset()
	add_to_group(&"widget_cleared")

func unclear():
	skip_to_end()
	remove_from_group(&"widget_cleared")

func get_rect_bound() -> Rect2:
	if image:
		return Rect2(Vector2.ZERO, image.size)
	return Rect2()

func _create_texture(data: PackedByteArray) -> Texture2D:
	var _image := Image.new()
	match entity.image_path.split(".")[-1]:
		"png": _image.load_png_from_buffer(data)
		"jpg": _image.load_jpg_from_buffer(data)
		"svg": _image.load_svg_from_buffer(data)
		"bmp": _image.load_bmp_from_buffer(data)
		_: push_error("Unsupported image format: " + entity.image_path.split(".")[-1])
	return ImageTexture.create_from_image(_image)

func _on_property_updated(property: EntityProperty) -> void:
	if property is PositionEntityProperty:
		position = property.position
	elif property is SizeEntityProperty:
		image.size = property.size
