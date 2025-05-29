class_name LeafController
extends NodeController

var _duration_leaf: float = 0.0
var leaf_value: Widget

func compute_duration() -> float:
	if is_zero_approx(_duration_leaf):
		_duration_leaf = _compute_duration()
	return _duration_leaf

func _compute_duration() -> float:
	return 0.0

func play(__duration: float, __total_real_time: float):
	#print(_class_node.entity.get_class_name() )
	#print(__duration," | - - - | ", __total_real_time)
	#print(_duration_leaf)
	if leaf_value == null:
		load_data(_class_node)
		var parent = leaf_value.get_parent()
		if parent != null:
			if is_audio():
				if leaf_value.get_parent() != root_audio_controller:
					#root_audio_controller.add_child(leaf_value)
					leaf_value.reparent(root_audio_controller)
		
			elif leaf_value.get_parent() != root_visual_controller_snapshot:
					#root_visual_controller_snapshot.add_child(leaf_value)
					leaf_value.reparent(root_visual_controller_snapshot)
		
		else:
			if is_audio():
				root_audio_controller.add_child(leaf_value)
			else:
				root_visual_controller_snapshot.add_child(leaf_value)
	
	var sigs: Array[Signal] = [leaf_value.termino, _bus_core.stop_widget]
	var state = SignalsCore.await_any_once(sigs)
	leaf_value.play(__duration, __total_real_time, _duration_leaf)
	if !state._done:
		await state.completed
		if state._signal_source == _bus_core.stop_widget:
			if leaf_value != null:
				leaf_value.stop()
			return 1

func play_tree(__duration: float, __total_real_time: float, last_child: NodeController = null) -> void:
	if __duration == 0.0 or is_audio() or __total_real_time == 0.0:
		var _duration_calculated = compute_duration_play(self, __duration, __total_real_time)
		__duration = _duration_calculated[0]
		__total_real_time = _duration_calculated[1]

	
	var state = await play(__duration, __total_real_time)
	if state == 1:
		return
	
	var parent = _class_node.get_parent_controller()
	if parent != null:
		parent.play_tree(__duration, __total_real_time, self)


func is_audio() -> bool:
	if _class_node.entity is AudioEntity:
		return true
	return false


static func instantiate(leaf: ClassNode) -> LeafController:
	var _class: String = leaf.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	var controller: LeafController = CustomClassDB.instantiate(_class)
	controller._class_node = leaf
	controller._duration = leaf.entity.duration
	return controller

func load_data(leaf: ClassLeaf) -> void:
	var entity_node: Widget = _instantiate_entity()
	if is_instance_valid(entity_node):
		leaf_value = entity_node
		

func _instantiate_entity() -> Widget:
	var entity: Entity = _class_node.entity
	if !_has_widget(entity):
		push_error("Error instantiating entity: " + entity.get_class_name() + ", widget not found")
		return null
	var widget: Widget = _get_widget(entity)
	widget.entity = entity
	widget.class_node = _class_node
	widget.init(_class_node.get_properties())
	return widget

func _has_widget(entity: Entity) -> bool:
	var _class: String = entity.get_class_name().replace("Entity", "Widget")
	return CustomClassDB.class_exists(_class)

func _get_widget(entity: Entity) -> Widget:
	var _class: String = entity.get_class_name().replace("Entity", "Widget")
	return CustomClassDB.instantiate(_class)


# Return the next node
func get_next(__current_node: Array) -> Array:
	var current_node =  __current_node[0]

	var parent = current_node._class_node.get_parent_controller()
	if parent != null:
		return [parent,current_node]
	return [null, null]

# Return the previous node
func get_previous(__current_node: Array) -> Array:
	var current_node =  __current_node[0]

	var parent = current_node._class_node.get_parent_controller()
	if parent != null:
		return [parent,current_node]
	return [null, null]
	

# Return the next leaf node
func get_next_leaf( last_child: NodeController ) -> LeafController:
	var parent = _class_node.get_parent_controller()
	if parent != null:
		return parent.get_next_leaf(self)
	return null

# Return the previous leaf node
func get_previous_leaf( last_child: NodeController ) -> LeafController:
	var parent = _class_node.get_parent_controller()
	if parent != null:
		return parent.get_previous_leaf(self)
	return null



# Return the next audio leaf node
func get_next_audio_after() -> LeafController:
	var leaf = get_next_leaf(self)
	var i = 0
	while leaf != null:
		i+=1
		if leaf.has_method("is_audio") and leaf.is_audio():
			break
		leaf = leaf.get_next_leaf(leaf)
	return leaf


# Return the previous audio leaf node
func get_previous_audio_before() -> LeafController:
	var leaf = get_previous_leaf(self)
	while leaf != null:
		if leaf.has_method("is_audio") and leaf.is_audio():
			break
		leaf = leaf.get_previous_leaf(leaf)
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
		current = current.get_next_leaf(current)
	return total


func compute_duration_play(current_node: NodeController, _duration: float, _total_real_time: float) -> Array[float]:
	var _previous_audio
	if current_node.has_method("is_audio") and current_node.is_audio():
		_previous_audio = current_node
		_duration = current_node.compute_duration()
	else:
		_previous_audio = get_previous_audio_before()
		_duration = _previous_audio.compute_duration()
	
	var _next_leaf_paudio = _previous_audio.get_next_leaf(_previous_audio)
	
	var _next_audio = get_next_audio_after()
	
	
	if _next_audio == null:
		if _next_leaf_paudio != null:
			_total_real_time = _next_leaf_paudio.compute_total_duration_between(null)
	else:
		var _prev_leaf_naudio = _next_audio.get_previous_leaf(_next_audio) #aqui
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(_prev_leaf_naudio)
	
	return [_duration, _total_real_time]


func get_last_clear() -> LeafController:
	if _class_node.entity is ClearEntity:
		return self
	var prev = get_previous_leaf(self)
	while prev != null:
		if prev._class_node.entity is ClearEntity:
			break
		prev = prev.get_previous_leaf(prev)
	return prev

func skip_to_end() -> void:
	
	if leaf_value == null:
		load_data(_class_node)
		
	var parent = leaf_value.get_parent()
	if parent != null:
		if is_audio():
			if leaf_value.get_parent() != root_audio_controller:
				#root_audio_controller.add_child(leaf_value)
				leaf_value.reparent(root_audio_controller)
	
		elif leaf_value.get_parent() != root_visual_controller_snapshot:
			#root_visual_controller_snapshot.add_child(leaf_value)
			leaf_value.reparent(root_visual_controller_snapshot)
	
	else:
		if is_audio():
			root_audio_controller.add_child(leaf_value)
		else:
			root_visual_controller_snapshot.add_child(leaf_value)
	
	
	
	var sigs: Array[Signal] = [leaf_value.termino]
	var state = SignalsCore.await_any_once(sigs)
	leaf_value.skip_to_end()
	
	if !state._done:
		await state.completed






func seek(node_seek: NodeController, last_child: NodeController = null) -> void:
	var current: NodeController = last_child
	var current_node = [current, null]
	while current != null:
		current.skip_to_end()
		if current == node_seek:
			return
		current_node = current.get_next(current_node)
		current = current_node[0]





######## Warning !!! Recursive calls can overflow the stack! #########

# Return the next audio leaf node
func _get_next_audio_after() -> LeafController:
	var leaf = get_next_leaf(self)
	while leaf != null and not leaf.is_audio():
		leaf = leaf.get_next_audio_after()
	return leaf

# Return the previous audio leaf node
func _get_previous_audio_before() -> LeafController:
	var leaf = get_previous_leaf(self)
	while leaf != null and not leaf.is_audio():
		leaf = leaf.get_previous_audio_before()
	return leaf

func recursive_seek(node_seek: NodeController, last_child: NodeController = null) -> void:
	
	skip_to_end()
	
	if node_seek == self:
		return

	var parent = _class_node.get_parent_controller()
	if parent != null:
		parent.recursive_seek(node_seek, self)
