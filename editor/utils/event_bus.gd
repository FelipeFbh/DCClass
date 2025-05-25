class_name EditorEventBus
extends Node

signal pen_toggled(active: bool)

signal request_detach()

## Emitted when the current node in the index tree changes and the new node is passed as an argument.
signal current_node_changed(node: ClassNode)

signal stop_play()

signal add_group(group: ClassGroup)

signal add_class_leaf(entity: Entity)

signal update_treeindex()
