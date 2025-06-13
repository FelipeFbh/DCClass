class_name NodeController
extends Node

static var root_node_controller: Node
static var root_visual_controller: Node2D
static var root_visual_controller_snapshot: Node2D
static var root_audio_controller: Node2D

@export var _class_node: ClassNode

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")

func _add_child_root() -> void:
	root_node_controller.add_child(self)

func self_delete() -> void:
	queue_free()
