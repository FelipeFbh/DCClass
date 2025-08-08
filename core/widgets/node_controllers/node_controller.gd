class_name NodeController
extends Node

static var root_node_controller: Node # This is the root node for all node controllers.
static var visual_widgets: Node2D # This is the root node for visual slides/widgets. Used for the visuals elements in the whiteboard.
static var visual_slide: Node2D # This is a slide for visual widgets.
static var audio_widgets: Node2D # This is the root node for audio widgets.

@export var _class_node: ClassNode

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")

# Add the controller to the root node controller.
func _add_child_root() -> void:
	root_node_controller.add_child(self)

# Delete the controller and free the resources.
func self_delete() -> void:
	queue_free()

# Skip to the end of the widget.
func skip_to_end() -> void:
	pass
