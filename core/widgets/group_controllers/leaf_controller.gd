class_name LeafController
extends NodeController

var _duration: float = 0.0
var _total_real_time: float = 0.0
var _duration_leaf: float = 0.0
var leaf_value: Widget
signal termino

func compute_duration() -> float:
	if is_zero_approx(_duration_leaf):
		_duration_leaf = _compute_duration()
	return _duration_leaf

func _compute_duration() -> float:
	return 0.0

func play(__duration: float = _duration, __total_real_time: float = _total_real_time):
	_bus_core.current_node_changed.emit(_class_node)
	var sigs: Array[Signal] = [leaf_value.termino, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	leaf_value.play(__duration, __total_real_time, _duration_leaf)
	if !state._done:
		await state.completed
		if state._signal_source == _bus_core.stop_widget:
			leaf_value.stop()
			return 1

func play_preorden(__duration: float = _duration, __total_real_time: float = _total_real_time, last_child: NodeController = null) -> void:
	if __duration == 0.0 or is_audio():
		var _duration_calculated = compute_duration_play(self, __duration, __total_real_time)
		__duration = _duration_calculated[0]
		__total_real_time = _duration_calculated[1]

	
	var state = await play(__duration, __total_real_time)
	if state == 1:
		return
	
	var parent = get_parent()
	if parent != null and parent.has_method("play_preorden"):
		parent.play_preorden(__duration, __total_real_time, self)

func is_audio() -> bool:
	if leaf_value.has_method("is_audio"):
		return leaf_value.is_audio()
	return false

func reset() -> void:
	pass


func skip_to_end() -> void:
	pass

static func instantiate(leaf: ClassNode, entities: Dictionary) -> LeafController:
	var _class: String = leaf.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	var controller: LeafController = CustomClassDB.instantiate(_class)
	controller.load_data(leaf, entities)
	controller._class_node = leaf
	return controller

func load_data(leaf: ClassLeaf, entities: Dictionary) -> void:
	var entity_node: Widget = _instantiate_entity(leaf._value, entities)
	if is_instance_valid(entity_node):
		leaf_value = entity_node
		_duration_leaf = leaf_value.compute_duration()
		add_child(leaf_value)

func _instantiate_entity(wrapper: EntityWrapper, entities: Dictionary) -> Widget:
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

# Return the previous audio leaf node
func get_previous_audio_before() -> LeafController:
	var leaf = get_previous_leaf_node()
	while leaf != null and not leaf.is_audio():
		leaf = leaf.get_previous_audio_before()
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


func compute_duration_play(current_node: NodeController, _duration: float = _duration, _total_real_time: float = _total_real_time) -> Array[float]:
	var _previous_audio
	if current_node.has_method("is_audio") and current_node.is_audio():
		_previous_audio = current_node
		_duration = current_node.compute_duration()
	else:
		_previous_audio = get_previous_audio_before()
		_duration = _previous_audio.compute_duration()
	
	var _next_leaf_paudio = _previous_audio.get_next_leaf_node()
	
	var _next_audio = get_next_audio_after()
	
	if _next_audio == null:
		if _next_leaf_paudio != null:
			_total_real_time = _next_leaf_paudio.compute_total_duration_between(null)
	else:
		var _prev_leaf_naudio = _next_audio.get_previous_leaf_node()
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(_prev_leaf_naudio)
	
	return [_duration, _total_real_time]
