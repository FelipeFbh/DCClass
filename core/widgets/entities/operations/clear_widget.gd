class_name ClearWidget
extends Widget

@export var entity: ClearEntity

signal termino

func init(_properties: Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	get_tree().call_group(&"widget_finished", "clear")

	var visual_widgets: Node2D = NodeController.visual_widgets
	var visual_slide: Node2D = NodeController.visual_slide
	var new_visual_slide: Node2D = Node2D.new()
	NodeController.visual_slide = new_visual_slide
	visual_widgets.add_child(new_visual_slide)
	emit_signal("termino")
	_bus_core.current_node_changed.emit(class_node)
	visual_widgets.remove_child(visual_slide)
	visual_slide.queue_free()


func reset():
	pass

func skip_to_end():
	get_tree().call_group(&"widget_finished", "clear")

	var visual_widgets: Node2D = NodeController.visual_widgets
	var visual_slide: Node2D = NodeController.visual_slide
	var new_visual_slide: Node2D = Node2D.new()
	NodeController.visual_slide = new_visual_slide
	visual_widgets.add_child(new_visual_slide)
	emit_signal("termino")
	visual_widgets.remove_child(visual_slide)
	visual_slide.queue_free()
