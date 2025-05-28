class_name GroupController
extends NodeController


var _childrens: Array[ClassNode] = []

# Returns the index of the controller in _childrens
func _index_of(current_node: NodeController) -> int:
	if current_node == null:
		return -1
	return _childrens.find(current_node._class_node)

# Return the next LeafController after last_child
func get_next_leaf(last_child: NodeController) -> LeafController:
	var index = _index_of(last_child)
		
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller()
		if parent != null:
			return parent.get_next_leaf(self)
		return
	
	var next_child = _childrens[index + 1]._node_controller
	return next_child.get_next_leaf(self)


# Return the previous LeafController before last_child
func get_previous_leaf(last_child: NodeController) -> LeafController:
	var index = _index_of(last_child)
		
	if _childrens.size() == 0 or index <= 0:
		var parent = _class_node.get_parent_controller()
		if parent != null:
			return parent.get_previous_leaf(self)
		return
	
	var prev_child = _childrens[index - 1]._node_controller
	return prev_child.get_previous_leaf(self)

# Return the next LeafController that is an audio
func get_next_audio_after(current_node: NodeController) -> LeafController:
	var leaf = get_next_leaf(current_node)
	while leaf != null and not leaf.is_audio():
		leaf = get_next_leaf(leaf)
	return leaf

# Return the previous LeafController that is an audio
func get_previous_audio_before(current_node: NodeController) -> LeafController:
	var leaf = get_previous_leaf(current_node)
	while leaf != null and not leaf.is_audio():
		leaf = get_previous_leaf(leaf)
	return leaf

# Return the total duration between start_leaf and end_leaf
func compute_total_duration_between(start_leaf: LeafController, end_leaf: LeafController) -> float:
	var total: float = 0.0
	var current: LeafController = start_leaf
	while current != null:
		total += current.compute_duration()
		if current == end_leaf:
			break
		current = current.get_next_leaf(current)
	return total


func _compute_duration_play(current_node: NodeController, _duration: float = 0.0, _total_real_time: float = 0.0) -> Array[float]:
	var _previous_audio
	if current_node.has_method("is_audio") and current_node.is_audio():
		_previous_audio = current_node
		_duration = current_node.compute_duration()
	else:
		_previous_audio = get_previous_audio_before(current_node)
		_duration = _previous_audio.compute_duration()
	
	var _next_leaf_paudio = _previous_audio.get_next_leaf()
	var _next_audio = get_next_audio_after(current_node)
	if _next_audio == null:
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(null)
	else:
		var _prev_leaf_naudio = _next_audio.get_previous_leaf(self)
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(_prev_leaf_naudio)
	
	return [_duration, _total_real_time]
	

# Play the group in pre-order
func play_preorden(__duration: float = 0.0, __total_real_time: float = 0.0, last_child: NodeController = null) -> void:
	var index = _index_of(last_child)
		
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller()
		if parent != null:
			parent.play_preorden(__duration, __total_real_time, self)
		return
	
	var next_child_to_play = _childrens[index + 1]._node_controller
	next_child_to_play.play_preorden(__duration, __total_real_time, self)


static func instantiate(group: ClassNode) -> NodeController:
	var _class: String = group.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	var controller: GroupController = CustomClassDB.instantiate(_class)
	controller._class_node = group
	controller._childrens = controller._class_node._childrens
	return controller


func get_last_clear() -> LeafController:
	var prev = get_previous_leaf(self)
	while prev != null and not (prev._class_node.entity is ClearEntity):
		prev = prev.get_previous_leaf(prev)
	return prev



func seek(node_seek: NodeController, last_child: NodeController = null ) -> void:

	if node_seek == self:
		return

	var index = _index_of(last_child)
		
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller()
		if parent != null:
			parent.seek(node_seek, self)
		return
	
	var next_child = _childrens[index + 1]._node_controller
	next_child.seek(node_seek, self)
