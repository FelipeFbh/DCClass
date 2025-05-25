class_name ClearWidget
extends Widget

@export var entity : ClearEntity

signal termino

func init(_properties: Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	_bus_core.emit_signal("clear_widget")
	emit_signal("termino")

func reset():
	pass

func skip_to_end():
	reset()
