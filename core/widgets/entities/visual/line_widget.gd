class_name LineWidget
extends Widget

const scene = preload("res://core/widgets/entities/visual/line_widget.tscn")

@export var entity: LineEntity
var line: Line2D
var tween: Tween

# Initialize the widget with properties.
func init(properties: Dictionary) -> void:
	line = scene.instantiate()
	add_child(line)
	if properties.has("position"):
		position = properties["position"]
	line.hide()

func serialize() -> Dictionary:
	return entity.serialize()

# Play the line widget.
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
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
