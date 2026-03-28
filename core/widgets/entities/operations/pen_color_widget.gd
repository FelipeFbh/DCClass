class_name PenColorWidget
extends Widget

@export var entity: PenColorEntity

func init(_properties: Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return entity.serialize()

# Play the pause operation.
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	Widget.pen_color = entity.color
	
	add_to_group(&"playing_widget")
	_bus_core.current_node_changed.emit(class_node)
	
	await get_tree().process_frame
	reset()

# Skip to the end of the pause operation. We omit the operation because the seek operation is to seek to a certain point.
func play_seek(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	Widget.pen_color = entity.color
	
	add_to_group(&"playing_widget")
	_bus_core.current_node_changed.emit(class_node)
	
	await get_tree().process_frame
	reset()

func reset():
	remove_from_group(&"widget_playing")
	add_to_group(&"widget_finished")
	emit_signal("widget_finished")

func stop() -> void:
	skip_to_end()

func skip_to_end():
	Widget.pen_color = entity.color
	add_to_group(&"widget_finished")
	emit_signal("widget_finished")
	
# Returns the duration of the operation in seconds.
func compute_duration() -> float:
	return 0.0
