class_name ClearWidget
extends Widget

@export var entity: ClearEntity

func init(_properties: Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return entity.serialize()


# Play the clear operation.
func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	# Call to all widgets to clear themselves if they are in the "widget_finished" group.
	get_tree().call_group(&"widget_finished", "clear")

	NodeController.pop_slide_layer()
	NodeController.hide_layers()
	NodeController.push_slide_layer()
	emit_signal("widget_finished")


func reset():
	pass

# Skip to the end of the clear operation. It is equivalent to play() since it is instant.
func skip_to_end():
	get_tree().call_group(&"widget_finished", "clear")

	NodeController.pop_slide_layer()
	emit_signal("widget_finished")
	NodeController.hide_layers()
	NodeController.push_slide_layer()
