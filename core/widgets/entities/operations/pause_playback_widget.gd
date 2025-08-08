class_name PausePlaybackWidget
extends Widget

@export var entity: PausePlaybackEntity


func init(_properties: Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return entity.serialize()

# Play the pause operation.
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	_bus_core.pause_playback_widget.emit()
	emit_signal("widget_finished", 2) # Special signal with 2 to indicate pause and stop the recursion of play.
	_bus_core.stop_widget.emit()
	get_tree().call_group(&"widget_playing", "stop")
	_bus_core.current_node_changed.emit(class_node)

# Skip to the end of the pause operation. We omit the operation because the seek operation is to seek to a certain point.
func play_seek(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	_bus_core.current_node_changed.emit(class_node)
	emit_signal("widget_finished")

func reset():
	pass

func skip_to_end():
	emit_signal("widget_finished")
