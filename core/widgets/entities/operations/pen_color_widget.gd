class_name PenColorWidget
extends Widget

@export var entity: PenColorEntity
@onready var _whiteboard: Node
var _color: Color = Color.WHITE

func init(_properties: Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return entity.serialize()

# Play the pause operation.
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	pass

# Skip to the end of the pause operation. We omit the operation because the seek operation is to seek to a certain point.
func play_seek(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	pass

func reset():
	pass

func skip_to_end():
	emit_signal("widget_finished")
