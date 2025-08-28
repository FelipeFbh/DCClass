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

	# Then reset the visual_slide by creating a new one and deleting the old one.
	var visual_widgets: Node2D = NodeController.visual_widgets
	var visual_slide: Node2D = NodeController.visual_slide
	var new_visual_slide: Node2D = Node2D.new()
	NodeController.visual_slide = new_visual_slide
	visual_widgets.add_child(new_visual_slide)
	emit_signal("widget_finished")
	_bus_core.current_node_changed.emit(class_node)
	visual_widgets.remove_child(visual_slide)
	visual_slide.queue_free()


func reset():
	pass

# Skip to the end of the clear operation. It is equivalent to play() since it is instant.
func skip_to_end():
	get_tree().call_group(&"widget_finished", "clear")

	var visual_widgets: Node2D = NodeController.visual_widgets
	var visual_slide: Node2D = NodeController.visual_slide
	var new_visual_slide: Node2D = Node2D.new()
	NodeController.visual_slide = new_visual_slide
	visual_widgets.add_child(new_visual_slide)
	emit_signal("widget_finished")
	visual_widgets.remove_child(visual_slide)
	visual_slide.queue_free()
