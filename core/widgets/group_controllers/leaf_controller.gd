class_name LeafController
extends NodeController

var _duration_leaf: float = 0.0
var leaf_value: Widget

func _setup(instance : ClassLeaf):
	_class_node = instance
	_duration_leaf = instance.entity.duration


func compute_duration() -> float:
	if is_zero_approx(_duration_leaf):
		_duration_leaf = _compute_duration()
	return _duration_leaf

func _compute_duration() -> float:
	return 0.0

func play(__duration: float, __total_real_time: float):
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
	return state._signal_value

func _play_seek(__duration: float, __total_real_time: float):
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
	leaf_value.play_seek(__duration, __total_real_time, _duration_leaf)
	if !state._done:
		await state.completed
		if state._signal_source == _bus_core.stop_widget:
			if leaf_value != null:
				leaf_value.stop()
			return 1
	return state._signal_value

func play_tree(__duration: float, __total_real_time: float, last_child: NodeController = null) -> void:
	if __duration == 0.0 or is_audio() or __total_real_time == 0.0:
		var _duration_calculated = compute_duration_play(self, __duration, __total_real_time)
		__duration = _duration_calculated[0]
		__total_real_time = _duration_calculated[1]
	
	var state = await play(__duration, __total_real_time)
	if state == 1 or state == 2:
		return
	
	var parent = _class_node.get_parent_controller()
	if parent != null:
		parent.play_tree(__duration, __total_real_time, self)

func play_seek(last_child: NodeController = null) -> void:
	var __duration = 0.0
	var __total_real_time = 0.0
	var _duration_calculated = compute_duration_play(self, __duration, __total_real_time)
	__duration = _duration_calculated[0]
	__total_real_time = _duration_calculated[1]
	
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
	
	leaf_value.reset()
	
	if not is_audio():
		var last_audio = get_previous_audio()
		var next_leaf_paudio = last_audio.get_next_leaf(last_audio)
		var prev_leaf = get_previous_leaf(self)
		if prev_leaf.is_audio():
			last_audio._seek_play(0.0)
		else:
			var time_seek = next_leaf_paudio.compute_total_duration_between(prev_leaf)
			last_audio._seek_play(time_seek * (__duration / __total_real_time))
	
	var state = await _play_seek(__duration, __total_real_time)
	if state == 1:
		return
	
	var parent = _class_node.get_parent_controller()
	if parent != null:
		parent.play_tree(__duration, __total_real_time, self)

func is_audio() -> bool:
	if _class_node.entity is AudioEntity:
		return true
	return false

func _seek_play(seek_time: float) -> void:
	leaf_value.seek(seek_time)

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


func self_delete() -> void:
	queue_free()


#region Tree Navigation

# Return the next node
func get_next(__current_node: Array) -> Array:
	var current_node = __current_node[0]

	var parent = current_node._class_node.get_parent_controller()
	if parent != null:
		return [parent, current_node]
	return [null, null]

# Return the previous node
func get_previous(__current_node: Array) -> Array:
	var current_node = __current_node[0]

	var parent = current_node._class_node.get_parent_controller()
	if parent != null:
		return [parent, current_node]
	return [null, null]
	

# Return the next leaf node
func get_next_leaf(last_child: NodeController) -> LeafController:
	var parent = _class_node.get_parent_controller()
	if parent != null:
		return parent.get_next_leaf(self)
	return null

# Return the previous leaf node
func get_previous_leaf(last_child: NodeController) -> LeafController:
	var parent = _class_node.get_parent_controller()
	if parent != null:
		return parent.get_previous_leaf(self)
	return null

#endregion


#region Playing Tree Utilities

func get_last_clear() -> LeafController:
	if _class_node.entity is ClearEntity:
		return self
	var prev = get_previous_leaf(self)
	while prev != null:
		if prev._class_node.entity is ClearEntity:
			break
		prev = prev.get_previous_leaf(prev)
	return prev


# Return the next audio leaf node
func get_next_audio() -> LeafController:
	var leaf = get_next_leaf(self)
	var i = 0
	while leaf != null:
		i += 1
		if leaf.has_method("is_audio") and leaf.is_audio():
			break
		leaf = leaf.get_next_leaf(leaf)
	return leaf


# Return the previous audio leaf node
func get_previous_audio() -> LeafController:
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
		_previous_audio = get_previous_audio()
		_duration = _previous_audio.compute_duration()
	
	var _next_leaf_paudio = _previous_audio.get_next_leaf(_previous_audio)
	
	var _next_audio = get_next_audio()
	
	
	if _next_audio == null:
		if _next_leaf_paudio != null:
			_total_real_time = _next_leaf_paudio.compute_total_duration_between(null)
	else:
		var _prev_leaf_naudio = _next_audio.get_previous_leaf(_next_audio)
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(_prev_leaf_naudio)
	
	return [_duration, _total_real_time]

#endregion

######## Warning !!! Recursive calls can overflow the stack! #########

# Return the next audio leaf node
func _get_next_audio() -> LeafController:
	var leaf = get_next_leaf(self)
	while leaf != null and not leaf.is_audio():
		leaf = leaf.get_next_audio()
	return leaf

# Return the previous audio leaf node
func _get_previous_audio() -> LeafController:
	var leaf = get_previous_leaf(self)
	while leaf != null and not leaf.is_audio():
		leaf = leaf.get_previous_audio()
	return leaf

func recursive_seek(node_seek: NodeController, last_child: NodeController = null) -> void:
	skip_to_end()
	
	if node_seek == self:
		return

	var parent = _class_node.get_parent_controller()
	if parent != null:
		parent.recursive_seek(node_seek, self)
