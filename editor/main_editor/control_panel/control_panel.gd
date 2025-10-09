class_name ControlPanel
extends MarginContainer

@onready var _bus_core: CoreEventBus = Engine.get_singleton(&"CoreSignals")
@onready var _bus: EditorEventBus = Engine.get_singleton(&"EditorSignals")

@onready var menu_btn_edit: MenuButton = %EditMenuButton
@onready var menu_btn_insert: MenuButton = %InsertMenuButton

@onready var btn_audio: CheckButton = %AudioButton
@onready var btn_pen: CheckButton = %PenButton
@onready var btn_detach: Button = %DetachButton
@onready var btn_zoom: Button = %ZoomButton

@onready var tree_manager: TreeManagerEditor = %IndexTree

@onready var pen_color_picker: ColorPickerButton = %ColorPickerButton
@onready var pen_color_label: Label = %ColorPickerLabel
@onready var pen_color_container: HBoxContainer = %PenColorContainer
var _pen_color_changed: bool = false
var _pending_pen_color: Color = Color.WHITE

@onready var pen_thickness_slider: HSlider = %PenThicknessSlider
@onready var pen_thickness_label: Label = %PenThicknessLabel
@onready var pen_thickness_container: HBoxContainer = %PenThicknessContainer
var _pen_thickness_timer: Timer
var _pending_pen_thickness: float = 2.0

var resources_class: ResourcesClassEditor

var _current_node: ClassNode
var _class_index: ClassIndex
var current_item_tree: TreeItem
var select_item_index_disabled: bool = false

# solo será true 1 vez con el primer trazo
var _first_stroke: bool = true
var _pen_color_changed_first: bool = false
var _pen_thickness_changed_first: bool = false

# zoom variables
var cam_pos: Vector2 = Vector2.ZERO
var zoom_level: float = 0
@onready var zoom_duration: HSlider = %ZoomDuration

func _ready() -> void:
	_bus_core.current_node_changed.connect(_current_node_changed)
	_bus.update_treeindex.connect(_setup_index_class)

	menu_btn_edit.get_popup().id_pressed.connect(_on_menu_btn_edit)
	_bus.disabled_toggle_edit_button.connect(_disabled_toggle_edit_button)
	
	menu_btn_insert.get_popup().id_pressed.connect(_on_menu_btn_insert)
	_bus.disabled_toggle_insert_button.connect(_disabled_toggle_insert_button)

	btn_audio.toggled.connect(_on_toggle_audio_pressed)
	_bus.disabled_toggle_audio_button.connect(_disabled_toggle_audio_button)
	
	btn_pen.toggled.connect(_on_button_pen_toggled)
	_bus.disabled_toggle_pen_button.connect(_disabled_toggle_pen_button)
	
	_bus.pen_started_drawing.connect(_on_pen_started_drawing)
		
	btn_detach.pressed.connect(_on_button_detach_pressed)
	
	btn_zoom.pressed.connect(_on_button_zoom_pressed)
	_bus.response_add_zoom.connect(_on_response_add_zoom)

	tree_manager.item_activated.connect(_on_item_activated)
	_bus.disabled_toggle_select_item_index.connect(_disabled_toggle_select_item_index)

	pen_thickness_slider.value_changed.connect(_on_thickness_slider_changed)
	
	_pen_thickness_timer = Timer.new()
	_pen_thickness_timer.wait_time = 0.3
	_pen_thickness_timer.one_shot = true
	_pen_thickness_timer.timeout.connect(_on_pen_thickness_changed)
	add_child(_pen_thickness_timer)
	
	pen_color_picker.color_changed.connect(_on_color_picker_changed)
	pen_color_picker.get_popup().connect("popup_hide", _on_color_picker_closed)
	
# Setup the control panel with the current resources class
func _setup():
	resources_class = PersistenceEditor.resources_class
	_setup_index_class()
	_current_node_changed(resources_class._current_node)

#region Menu Edit

func _on_menu_btn_edit(id: int) -> void:
	if id == 1:
		_copy_to_clipboard()
	if id == 2:
		_cut_to_clipboard()
	if id == 3:
		_paste()
	if id == 4:
		_delete()

func _disabled_toggle_edit_button(active: bool) -> void:
	menu_btn_edit.disabled = active

func _copy_to_clipboard() -> void:
	var first = tree_manager.get_next_selected(null)

	if first == null:
		return
	
	var nodes_copy: Array[ClassNode] = []
	var current = first
	
	while current:
		nodes_copy.append(current.get_metadata(0))
		current = tree_manager.get_next_selected(current)
	
	PersistenceEditor.clipboard.clear()
	PersistenceEditor.clipboard_clear_files()

	for node in nodes_copy:
		if node is ClassLeaf:
			var node_copy: ClassNode = node.copy_tmp()
			node_copy._setup_controller(false)
			PersistenceEditor.clipboard.append(node_copy)

		
		elif node is ClassGroup:
			var data_new = {
				"name": "Group",
				"type": "ClassGroup",
				"childrens": []
			}
			var new_node = ClassGroup.deserialize(data_new)
			PersistenceEditor.clipboard.append(new_node)

func _cut_to_clipboard() -> void:
	_copy_to_clipboard()
	_delete()

func _paste() -> void:
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.paste_class_nodes.emit()


func _delete() -> void:
	var first = tree_manager.get_next_selected(null)
	if first == null:
		return
	var nodes_del: Array[ClassNode] = []
	var current = first
	
	while current:
		nodes_del.append(current.get_metadata(0))
		current = tree_manager.get_next_selected(current)
	
	_bus.delete_class_nodes.emit(nodes_del)

	
#endregion


#region Menu Insert

# Handle the insert menu button actions
func _on_menu_btn_insert(id: int) -> void:
	if id == 1:
		_add_group()
	if id == 2:
		_push_group()
	if id == 3:
		_make_group()
	if id == 4:
		_add_clear()
	if id == 5:
		_add_pause()
	if id == 6:
		_add_color_change()
	if id == 7:
		_add_thickness_change()
	if id == 8:
		_add_zoom()

func _disabled_toggle_insert_button(active: bool) -> void:
	menu_btn_insert.disabled = active

# Add a new group at the beginning of the current node
func _add_group() -> void:
	var data_new = {
		"name": "Group",
		"type": "ClassGroup",
		"childrens": []
	}
	var class_node = ClassGroup.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_group.emit(class_node, true)

# Push a new group to the end of the current node
func _push_group() -> void:
	var data_new = {
		"name": "Group",
		"type": "ClassGroup",
		"childrens": []
	}
	var class_node = ClassGroup.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_group.emit(class_node, false)

func _make_group() -> void:
	var first = tree_manager.get_next_selected(null)

	if first == null:
		return
	
	var nodes_to_group: Array[ClassNode] = []
	var current = first
	
	while current:
		nodes_to_group.append(current.get_metadata(0))
		current = tree_manager.get_next_selected(current)
	
	PersistenceEditor.clipboard.clear()
	PersistenceEditor.clipboard_clear_files()

	for node in nodes_to_group:
		PersistenceEditor.clipboard.append(node)
	_bus.make_group.emit()


# Add a clear entity after the current node
func _add_clear() -> void:
	var entity_clear = ClearEntity.new()
	var data_new = {
		"type": "ClassLeaf",
		"entity_id": entity_clear.entity_id,
		"entity_properties": []
	}
	var class_node = ClassLeaf.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_leaf.emit(class_node)

func _add_pause() -> void:
	var entity_pause = PausePlaybackEntity.new()
	var data_new = {
		"type": "ClassLeaf",
		"entity_id": entity_pause.entity_id,
		"entity_properties": []
	}
	var class_node = ClassLeaf.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_leaf.emit(class_node)

func _add_color_change() -> void:
	var entity_color_change = PenColorEntity.new()
	var data_new = {
		"type": "ClassLeaf",
		"entity_id": entity_color_change.entity_id,
		"entity_properties": []
	}
	var class_node = ClassLeaf.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_leaf.emit(class_node)

func _add_thickness_change() -> void:
	var entity_thickness_change = PenThicknessEntity.new()
	var data_new = {
		"type": "ClassLeaf",
		"entity_id": entity_thickness_change.entity_id,
		"entity_properties": []
	}
	
	var class_node = ClassLeaf.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
	_bus.add_class_leaf.emit(class_node)

func _add_zoom():
	var entity_zoom = ZoomEntity.new()
	var data_new = {
		"type": "ClassLeaf",
		"entity_id": entity_zoom.entity_id,
		"entiy_properties": [{
			"position:x": position.x,
			"position:y": position.y,
			"zoom_level": zoom_level,
			"zoom_duration": zoom_duration.value
		}] 
	}
	var class_node = ClassLeaf.deserialize(data_new)
	var first = tree_manager.get_next_selected(null)
	
	if first != null:
		PersistenceEditor.resources_class._current_node = first.get_metadata(0)
		_bus.add_class_leaf.emit(class_node)
	
#endregion


#region Whiteboard Interactions

# Toggle audio recording
func _on_toggle_audio_pressed(active: bool) -> void:
	_bus.audio_record.emit(active)
	if active:
		PersistenceEditor._epilog(PersistenceEditor.Status.RECORDING_AUDIO)
	else:
		PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)

func _disabled_toggle_audio_button(active: bool) -> void:
	btn_audio.disabled = active

# Toggle pen mode
func _on_button_pen_toggled(active: bool) -> void:
	_bus.pen_toggled.emit(active)
	if active:
		PersistenceEditor._epilog(PersistenceEditor.Status.RECORDING_PEN)
	else:
		PersistenceEditor._epilog(PersistenceEditor.Status.STOPPED)
	
func _disabled_toggle_pen_button(active: bool) -> void:
	btn_pen.disabled = active

# Request to detach the whiteboard
func _on_button_detach_pressed() -> void:
	_bus.request_detach.emit()
	
# Request to take screenshot of the whiteboard
func _on_button_zoom_pressed() -> void:
	_bus.request_zoom.emit()

func _on_response_add_zoom(position: Vector2, zoom: float) -> void:
	cam_pos = position
	zoom_level = zoom
	 
#endregion


#region Tree Index

# Setup the index class and build the tree structure
func _setup_index_class():
	_class_index = resources_class.class_index
	var entities = _class_index.entities
	var root_tree_structure = _class_index.tree_structure
	
	tree_manager.tree_manager_index = tree_manager
	tree_manager.build(root_tree_structure, entities)

# Select an item in the tree and update the current node
func _on_item_activated() -> void:
	if select_item_index_disabled:
		return
	var item = tree_manager.get_selected()
	var node = item.get_metadata(0)
	_bus_core.current_node_changed.emit(node)
	_bus.seek_node.emit(node)

func _disabled_toggle_select_item_index(active: bool) -> void:
	select_item_index_disabled = active

# Update the current node
func _current_node_changed(current_node):
	if current_item_tree != null:
		current_item_tree.set_custom_color(0, Color.GRAY)
	current_item_tree = tree_manager.find_item_by_node(current_node)
	tree_manager.scroll_to_item(current_item_tree, true)
	current_item_tree.set_custom_color(0, Color.LIME_GREEN)
	_current_node = current_node

func _on_pen_thickness_changed():
	_bus.pen_thickness_changed.emit(_pending_pen_thickness)
	
	var thickness_entity := PenThicknessEntity.new()
	thickness_entity.thickness = _pending_pen_thickness
	
	_bus.add_class_leaf_entity.emit(thickness_entity, [])

func _on_pen_color_changed(color: Color) -> void:
	_bus.pen_color_changed.emit(color)
		
	var color_entity := PenColorEntity.new()
	color_entity.color = color
	
	_bus.add_class_leaf_entity.emit(color_entity, [])

func _on_color_picker_changed(color: Color) -> void:
	_pending_pen_color = color
	_pen_color_changed = true
	_pen_color_changed_first = true
	
func _on_color_picker_closed() -> void:
	if _pen_color_changed:
		_on_pen_color_changed(_pending_pen_color)
		_pen_color_changed = false
	
func _on_thickness_slider_changed(value: float) -> void:
	_pending_pen_thickness = value
	_pen_thickness_timer.start()
	_pen_thickness_changed_first = true

func _on_pen_started_drawing() -> void:
	if _first_stroke:
		if _pen_color_changed_first and !_pen_thickness_changed_first:
			var thickness_entity := PenThicknessEntity.new()
			thickness_entity.thickness = _pending_pen_thickness
			_bus.add_class_leaf_entity.emit(thickness_entity, [])
		
		if _pen_thickness_changed_first and !_pen_color_changed_first:
			var color_entity := PenColorEntity.new()
			color_entity.color = pen_color_picker.color
			_bus.add_class_leaf_entity.emit(color_entity, [])
		
		if !_pen_thickness_changed_first and !_pen_color_changed_first:
			var color_entity := PenColorEntity.new()
			color_entity.color = pen_color_picker.color
			_bus.add_class_leaf_entity.emit(color_entity, [])
			
			var thickness_entity := PenThicknessEntity.new()
			thickness_entity.thickness = _pending_pen_thickness
			_bus.add_class_leaf_entity.emit(thickness_entity, [])
		
		_first_stroke = false
		
#endregion
