class_name CoreEventBus
extends Node

signal clear_widget()

signal stop_widget()

## Emitted when the current node in the index tree changes and the new node is passed as an argument.
signal current_node_changed(node : ClassNode)
