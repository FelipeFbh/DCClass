class_name LeafController
extends NodeController

var _duration: float = 0.0
var _total_real_time: float = 0.0
var _duration_leaf: float = 0.0

var leaf_value: Widget

func compute_duration() -> float:
	if is_zero_approx(_duration_leaf):
		_duration_leaf = _compute_duration()
	return _duration_leaf

func _compute_duration() -> float:
	return 0.0


func play(__duration: float = _duration, __total_real_time: float = _total_real_time) -> void:
	var _bus : EditorEventBus = Engine.get_singleton(&"EditorSignals")
	_bus.current_node_leaf_changed.emit(_class_node)
	await leaf_value.play(__duration, __total_real_time, _duration_leaf)

func is_audio() -> bool:
	if leaf_value.has_method("is_audio"):
		return leaf_value.is_audio()
	return false

func reset() -> void:
	pass


func skip_to_end() -> void:
	pass

static func instantiate(leaf: ClassNode, entities: Array[Entity]) -> LeafController:
	var _class: String = leaf.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	var controller: LeafController = CustomClassDB.instantiate(_class)
	controller.load_data(leaf, entities)
	controller._class_node = leaf
	return controller

func load_data(leaf: ClassLeaf, entities: Array[Entity]) -> void:
	var entity_node: Widget = _instantiate_entity(leaf._value, entities)
	if is_instance_valid(entity_node):
		leaf_value = entity_node
		_duration_leaf = leaf_value.compute_duration()
		add_child(leaf_value)

func _instantiate_entity(wrapper: EntityWrapper, entities: Array[Entity]) -> Widget:
	var entity: Entity = entities[wrapper.entity_id]
	if !_has_widget(entity):
		push_error("Error instantiating entity: " + entity.get_class_name() + ", widget not found")
		return null
	var widget: Widget = _get_widget(entity)
	widget.entity = entity
	widget.init(wrapper.get_properties())
	return widget

func _has_widget(entity: Entity) -> bool:
	var _class: String = entity.get_class_name().replace("Entity", "Widget")
	return CustomClassDB.class_exists(_class)

func _get_widget(entity: Entity) -> Widget:
	var _class: String = entity.get_class_name().replace("Entity", "Widget")
	return CustomClassDB.instantiate(_class)


# Return the next leaf node
func get_next_leaf_node() -> LeafController:
	var parent = get_parent()
	if parent != null:
		return parent.get_next_leaf_node(self)
	return null

# Return the previous leaf node
func get_previous_leaf_node() -> LeafController:
	var parent = get_parent()
	if parent != null:
		return parent.get_previous_leaf_node(self)
	return null

# Return the next audio leaf node
func get_next_audio_after() -> LeafController:
	var leaf = get_next_leaf_node()
	while leaf != null and not leaf.is_audio():
		leaf = leaf.get_next_audio_after()
	return leaf

# Return the total duration between start_leaf and end_leaf
# Start_leaf is the current leaf node (self)
func compute_total_duration_between(end_leaf: LeafController) -> float:
	var total: float = 0.0
	var current: LeafController = self
	while current != null:
		total += current.compute_duration()
		if current == end_leaf:
			break
		current = current.get_next_leaf_node()
	return total
