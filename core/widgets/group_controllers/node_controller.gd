class_name NodeController
extends Node

static var root_node_controller : Node
static var root_visual_controller : Node2D
static var root_visual_controller_snapshot : Node2D
static var root_audio_controller : Node2D

@export var _class_node: ClassNode

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
func _init():
	_bus_core = Engine.get_singleton("CoreSignals") as CoreEventBus
	root_node_controller.add_child(self)


static func instantiate(node: ClassNode) -> NodeController:
	var _class: String = node.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	
	var controller: NodeController = CustomClassDB.instantiate(_class)
	controller.load_data(node)
	controller._class_node = node
	return controller
