class_name CoreEventBus
extends Node


# Emitted when the current node in the index tree changes and the new node is passed as an argument.
signal current_node_changed(current_node: ClassNode)

signal tree_play_finished()

# Emitted when the widget have to be stopped.
signal stop_widget()

signal pause_playback_widget()
