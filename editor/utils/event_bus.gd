class_name EditorEventBus
extends Node

# This bus is used to communicate the editor events in the application.

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

# Pen Thickness Changed
signal pen_thickness_changed(value: float)

# Pen Color Changed
signal pen_color_changed(color: Color)

#endregion

#region Resources

# Add a group after the current node. In case of being the current node being a group, it will follow the next logic:
# back -> indicates how the group is added. 
# If true, the group is added at the begin
# if false, the group is added at the end.
signal add_class_group(group: ClassGroup, back: bool)

signal add_class_leaf(entity: Entity)

signal add_class_leaf_entity(entity: Entity, entity_properties)

signal paste_class_nodes()

signal delete_class_nodes(node: Array[ClassNode])

signal make_group()

#endregion


#region Whiteboard

# Toggle pen
signal pen_toggled(active: bool)

# Pen draw detection
signal pen_started_drawing

# Audio record
signal audio_record(active: bool)

# Pressed zoom
signal request_zoom

# Add zoom to queue
signal response_add_zoom(camera_position: Vector2, zoom: float)

# Pressed detach
signal request_detach

# Seek the visual for a node
signal seek_node(node: ClassNode)

# Play from the current node
signal seek_play()

# Toggle the Stop button
signal disabled_toggle_stop_button(active: bool)

# Toggle the Play(Stop) button
signal status_playback_stop(active : bool)

#endregion
