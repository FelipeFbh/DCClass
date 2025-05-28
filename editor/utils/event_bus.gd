class_name EditorEventBus
extends Node

signal pen_toggled(active: bool)

signal request_detach()

signal add_class_group(group: ClassGroup, back: bool)

signal add_class_leaf(entity: Entity)

signal add_class_leaf_entity(entity: Entity)

signal update_treeindex()

signal seek_node(node: ClassNode)
