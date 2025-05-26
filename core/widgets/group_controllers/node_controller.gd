class_name NodeController
extends Node2D

var _class_node: ClassNode
@onready var _bus_core : CoreEventBus = Engine.get_singleton(&"CoreSignals")


static func instantiate(node: ClassNode, entities: Dictionary) -> NodeController:
	var _class: String = node.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	
	var controller: NodeController = CustomClassDB.instantiate(_class)
	controller.load_data(node, entities)
	controller._class_node = node
	return controller
