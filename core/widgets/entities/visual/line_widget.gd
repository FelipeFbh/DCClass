class_name LineWidget
extends Widget

const scene = preload("res://core/widgets/entities/visual/line_widget.tscn")

@export var entity: LineEntity
var line: Line2D
var tween: Tween
var bound = null
var _original_bound: Rect2

# Initialize the widget with properties.
func init(properties: Dictionary) -> void:
	line = scene.instantiate()
	add_child(line)
	if properties.has("position"):
		position = properties["position"]
	line.hide()
	
	if class_node is ClassLeaf:
		(class_node as ClassLeaf).property_updated.connect(_on_property_updated)

func serialize() -> Dictionary:
	return entity.serialize()

# Play the line widget.
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	line.default_color = Widget.pen_color
	line.width = Widget.pen_thickness
	line.show()
	
	if tween:
		tween.kill()

	var pts = entity.points
	var delays = entity.delays
	
	var count = pts.size()
	if count == 0:
		return

	tween = create_tween()

	tween.set_speed_scale(1 / (_duration / _total_real_time)) # Set the speed scale to match the duration with his respective time.
	
	
	# With the callback of the function "add_points" we add points to the line after each delay.
	for i in range(count):
		tween.tween_callback(Callable(self, "_add_points").bind(i))
		if i < delays.size():
			tween.tween_interval(delays[i])

	add_to_group(&"playing_widget")
	_bus_core.current_node_changed.emit(class_node)
	tween.play()
	
	await tween.finished
	
	remove_from_group(&"widget_playing")
	add_to_group(&"widget_finished")

	emit_signal("widget_finished")

# Reset the line widget to its initial state.
# This means hiding the line and clearing its points.
func reset():
	if tween:
		tween.kill()
	line.hide()
	line.clear_points()
	remove_from_group(&"widget_playing")
	remove_from_group(&"widget_finished")
	emit_signal("widget_finished")


func stop() -> void:
	skip_to_end()
	

# Skip to the end of the line widget.
# This means setting the points of the line to the entity's points and showing the line.
func skip_to_end() -> void:
	if tween:
		tween.kill()
	line.points = entity.points
	line.default_color = Widget.pen_color
	line.width = Widget.pen_thickness
	line.show()
	add_to_group(&"widget_finished")
	emit_signal("widget_finished")

# Add a point to the line at the specified index of the array of points.
func _add_points(i: int) -> void:
	if not line.points.is_empty() and line.points[-1] == entity.points[i]:
		return # to avoid duplicate points
	line.add_point(entity.points[i])

# Clear the line widget.
# This means resetting the line and removing it from the groups.
func clear():
	reset()
	add_to_group(&"widget_cleared")

# Unclear the line widget.
# This means resetting to the visual state.
func unclear():
	skip_to_end()
	remove_from_group(&"widget_cleared")

# Returns the duration of the line in seconds.
func compute_duration() -> float:
	var duration: float = 0.0
	var delays = entity.delays
	if delays.size() > 0:
		for i in range(delays.size()):
			duration += delays[i]
	return duration

# Get bounds as Array of Vector2
func get_rect_bound() -> Rect2:
	if not bound:
		bound = _compute_bounds()
	return bound

# Return the boundaries vector that contains the line
func _compute_bounds() -> Rect2:
	var points = entity.points
	if points.is_empty():
		return Rect2()
	
	# init with first point
	var min_x = points[0].x
	var max_x = points[0].y
	var min_y = points[0].x
	var max_y = points[0].y
	
	# find min max
	for point in points:
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)
		max_x = max(max_x, point.x)
		max_y = max(max_y, point.y)
	
	# set the vectors
	var tl = Vector2(min_x, min_y)
	var br = Vector2(max_x, max_y)

	return Rect2(tl, br - tl)

func _on_property_updated(property: EntityProperty) -> void:
	if property is PositionEntityProperty:
		position = property.position
	elif property is SizeEntityProperty:
		# Guardar el bound original si no existe
		if _original_bound == Rect2():
			_original_bound = get_rect_bound()
		
		# Si el bound original es válido, transformar los puntos
		if _original_bound.size.x > 0 and _original_bound.size.y > 0:
			var new_bound = Rect2(_original_bound.position, property.size)
			
			# Calcular la escala
			var scale_x = new_bound.size.x / _original_bound.size.x
			var scale_y = new_bound.size.y / _original_bound.size.y
			 
			# Transformar cada punto
			var new_points: PackedVector2Array = []
			for point in entity.points:
				# Normalizar punto respecto al bound original
				var normalized = (point - _original_bound.position) / _original_bound.size
				# Aplicar al nuevo bound
				var new_point = new_bound.position + (normalized * new_bound.size)
				new_points.append(new_point)
			
			# Actualizar entity y visual
			entity.points = new_points
			line.points = new_points
			
			# Invalidar bound cacheado
			bound = null
			
			# Actualizar el original bound para futuros resizes
			_original_bound = new_bound
