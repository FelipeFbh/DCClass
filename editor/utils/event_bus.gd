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

# Toggle Zoom Button
signal disabled_toggle_zoom_button(active: bool)

# Pen Thickness Changed
signal pen_thickness_changed(value: float)

# Pen Color Changed
signal pen_color_changed(color: Color)

# Toggle Drag Button
signal disabled_toggle_drag_button(active: bool)

#endregion

#region TreeItem - Whiteboard Rendering

# Signal called after rendering on seek
signal execute_after_rendering()

# Emit class node from tree items that are selected or unselected
signal class_node_selected(node: ClassNode, selected: bool)

#endregion

#region Resources

# Add a group after the current node. In case of being the current node being a group, it will follow the next logic:
# back -> indicates how the group is added. 
# If true, the group is added at the begin
# if false, the group is added at the end.
signal add_class_group(group: ClassGroup, back: bool)

signal add_class_slide(slide: ClassSlide, back: bool)

signal add_class_leaf(entity: Entity)

signal add_class_leaf_entity(entity: Entity, entity_properties)

signal paste_class_nodes()

signal delete_class_nodes(node: Array[ClassNode])

signal make_group()

#endregion


#region Whiteboard

# Toggle pen
signal pen_toggled(active: bool)

# Toogle zoom
signal zoom_toggled(active: bool)

# Drag toggled
signal drag_toggled(active: bool)

# Seek the visual for a node
signal seek_node(node: ClassNode)

# Play from the current node
signal seek_play()

# Toggle the Stop button
signal disabled_toggle_stop_button(active: bool)

# Toggle the Play(Stop) button
signal status_playback_stop(active : bool)

#endregion
