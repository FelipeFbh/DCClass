class_name EditorEventBus
extends Node


#region Control Panel

# Update the tree index.
signal update_treeindex()

# Toggle Select Item Index Disabled
signal disabled_toggle_select_item_index(active: bool)

# Toggle disabled Edit Button
signal disabled_toggle_edit_button(active: bool)

# Toggle Insert Button
signal disabled_toggle_insert_button(active: bool)

# Toggle Audio Button
signal disabled_toggle_audio_button(active: bool)

# Toggle Pen Button
signal disabled_toggle_pen_button(active: bool)

#endregion

#region Resources

signal add_class_group(group: ClassGroup, back: bool)

signal add_class_leaf(entity: Entity)

signal add_class_leaf_entity(entity: Entity, entity_properties)

signal paste_class_nodes()

signal delete_class_nodes(node: Array[ClassNode])

#endregion


#region Whiteboard

# Toggle pen
signal pen_toggled(active: bool)

# Seek the visual for a node
signal seek_node(node: ClassNode)

# Play from the current node
signal seek_play()

# Toggle the Stop button
signal disabled_toggle_stop_button(active: bool)

signal status_playback_stop(active : bool)

#endregion
