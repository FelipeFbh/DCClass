class_name CoreEventBus
extends Node


# Emitted when the current node in the index tree changes and the new node is passed as an argument.
signal current_node_changed(current_node: ClassNode)

# Emitted when the widget have to be stopped.
signal stop_widget()
