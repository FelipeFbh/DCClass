class_name ClearWidget
extends Widget

@export var entity : ClearEntity

signal termino

func init(_properties: Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return entity.serialize()

func play(_duration: float, _total_real_time: float, _duration_leaf: float) -> void:
	get_tree().call_group(&"widget_finished", "clear")

	var visual_root : Node2D = NodeController.root_visual_controller
	var visual_snapshot : Node2D = NodeController.root_visual_controller_snapshot
	var new_visual_snapshot : Node2D =  Node2D.new()
	NodeController.root_visual_controller_snapshot = new_visual_snapshot
	visual_root.add_child(new_visual_snapshot)
	emit_signal("termino")
	_bus_core.current_node_changed.emit(class_node)
	visual_root.remove_child(visual_snapshot)
	#visual_snapshot.free() # Inmediato EN ejecucion. Para objetos.
	#visual_snapshot.call_deferred("free") # Al final del frame llama free.
	visual_snapshot.queue_free() #Al final del Frame. Solo para Node.


func reset():
	pass

func skip_to_end():
	get_tree().call_group(&"widget_finished", "clear")

	var visual_root : Node2D = NodeController.root_visual_controller
	var visual_snapshot : Node2D = NodeController.root_visual_controller_snapshot
	var new_visual_snapshot : Node2D =  Node2D.new()
	NodeController.root_visual_controller_snapshot = new_visual_snapshot
	visual_root.add_child(new_visual_snapshot)
	emit_signal("termino")
	visual_root.remove_child(visual_snapshot)
	visual_snapshot.queue_free()
