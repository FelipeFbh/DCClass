class_name NodeController
extends Node

static var root_node_controller: Node # This is the root node for all node controllers.
static var visual_widgets: Node2D # This is the root node for visual slides/widgets. Used for the visuals elements in the whiteboard.
static var visual_slide: Node2D # This is a slide for visual widgets.
static var audio_widgets: Node2D # This is the root node for audio widgets.

@export var _class_node: ClassNode

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

func _add_child_root() -> void:
	root_node_controller.add_child(self)

func self_delete() -> void:
	queue_free()

func clear_collapsed() -> void:
	remove_from_group(&"skipped_on_collapsed")
