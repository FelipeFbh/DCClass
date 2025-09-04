class_name ImageWidget
extends Widget

const scene = preload("res://core/widgets/entities/visual/image_widget.tscn")

@export var entity: ImageEntity
var image: TextureRect
var tween: Tween

func init(properties: Dictionary) -> void:
	if !Widget.zip_file.file_exists(entity.image_path):
		push_error("Image file not found: " + entity.image_path)
		return
	var data := Widget.zip_file.read_file(entity.image_path)
	var texture := _create_texture(data)
	var image = scene.instantiate()
	add_child(image)
	if properties.has("position"):
		position = properties["position"]
	if properties.has("size"):
		image.size = properties["size"]
	image.texture = texture

func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	#image.modulate = Color(1,1,1,0)
	image.show()
	#tween = create_tween()
	#tween.tween_property(image, "modulate", Color(1, 1, 1, 1), entity.duration)
	add_to_group(&"widget_finished")
	emit_signal("termino")

func reset():
	if tween:
		tween.kill()
	image.hide()
	remove_from_group(&"widget_finished")
	emit_signal("termino")

func skip_to_end() -> void:
	if tween:
		tween.kill()
	image.show()
	# image.modulate = Color(1, 1, 1, 1)
	remove_from_group(&"widget_finished")
	emit_signal("termino")

func clear():
	reset()

func _create_texture(data: PackedByteArray) -> Texture2D:
	var _image := Image.new()
	match entity.image_path.split(".")[-1]:
		"png": _image.load_png_from_buffer(data)
		"jpg": _image.load_jpg_from_buffer(data)
		"svg": _image.load_svg_from_buffer(data)
		"bmp": _image.load_bmp_from_buffer(data)
		_: push_error("Unsupported image format: " + entity.image_path.split(".")[-1])
	return ImageTexture.create_from_image(_image)
