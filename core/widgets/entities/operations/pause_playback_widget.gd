class_name PausePlaybackWidget
extends Widget

@export var entity : PausePlaybackEntity

signal termino( value : int )

func init(_properties: Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	_bus_core.pause_playback_widget.emit()
	emit_signal("termino", 2)
	_bus_core.stop_widget.emit()
	get_tree().call_group(&"widget_playing", "stop")
	_bus_core.current_node_changed.emit(class_node)

func play_seek(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	_bus_core.current_node_changed.emit(class_node)
	emit_signal("termino")

func reset():
	pass

func skip_to_end():
	emit_signal("termino")
