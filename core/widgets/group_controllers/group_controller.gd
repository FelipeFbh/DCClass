class_name GroupController
extends NodeController


var _childrens: Array[NodeController] = []

# Return the first LeafController in this group
func get_first_leaf() -> LeafController:
	if _childrens.is_empty():
		return null
	var first = _childrens[0]
	if first is LeafController:
		return first
	for i in range(_childrens.size()):
		if _childrens[i] is LeafController:
			return _childrens[i]
		var leaf = _childrens[i].get_first_leaf()
		if leaf != null:
			return leaf
	return null

# Return the next controller in the group
# If there is no next controller, it will return the next controller in the parent group
func next(current_node: NodeController) -> NodeController:
	var index = _childrens.find(current_node)
	if index >= 0 and index + 1 < _childrens.size():
		return _childrens[index + 1]
	var parent = get_parent()
	if parent != null and parent is GroupController:
		return parent.next(current_node)
	return null

# Return the previous controller in the group
# If there is no previous controller, it will return the previous controller in the parent group
func previous(current_node: NodeController) -> NodeController:
	var index = _childrens.find(current_node)
	if index > 0:
		return _childrens[index - 1]
	var parent = get_parent()
	if parent != null and parent is NodeController:
		return parent.previous(current_node)
	return null

# Return the next LeafController after current_node
func get_next_leaf_node(current_node: NodeController) -> LeafController:
	var next = self.next(current_node)
	while next != null:
		if next is LeafController:
			return next
		var first_leaf_inside = next.get_first_leaf()
		if first_leaf_inside != null:
			return first_leaf_inside
		next = self.next(next)
	return null

# Return the last LeafController in this group
func get_last_leaf() -> LeafController:
	for i in range(_childrens.size() - 1, -1, -1): # Iterate backwards to find the last leaf, in case of a final groups without leaves
		var child = _childrens[i]
		if child is LeafController:
			return child
		var leaf = child.get_last_leaf()
		if leaf != null:
			return leaf
	return null

# Return the previous LeafController before current_node
func get_previous_leaf_node(current_node: NodeController) -> LeafController:
	var prev = self.previous(current_node)
	while prev != null:
		if prev is LeafController:
			return prev
		var last_leaf_inside = prev.get_last_leaf()
		if last_leaf_inside != null:
			return last_leaf_inside
		prev = self.previous(prev)
	return null

# Return the next LeafController that is an audio
func get_next_audio_after(current_node: NodeController) -> LeafController:
	var leaf = get_next_leaf_node(current_node)
	while leaf != null and not leaf.is_audio():
		leaf = get_next_leaf_node(leaf)
	return leaf

# Return the previous LeafController that is an audio
func get_previous_audio_before(current_node: NodeController) -> LeafController:
	var leaf = get_previous_leaf_node(current_node)
	while leaf != null and not leaf.is_audio():
		leaf = get_previous_leaf_node(leaf)
	return leaf

# Return the total duration between start_leaf and end_leaf
func compute_total_duration_between(start_leaf: LeafController, end_leaf: LeafController) -> float:
	var total: float = 0.0
	var current: LeafController = start_leaf
	while current != null:
		total += current.compute_duration()
		if current == end_leaf:
			break
		current = get_next_leaf_node(current)
	return total


func _compute_duration_play(current_node: NodeController, _duration: float = 0.0, _total_real_time: float = 0.0) -> Array[float]:
	var _previous_audio
	if current_node.has_method("is_audio") and current_node.is_audio():
		_previous_audio = current_node
		_duration = current_node.compute_duration()
	else:
		_previous_audio = get_previous_audio_before(current_node)
		_duration = _previous_audio.compute_duration()
	
	var _next_leaf_paudio = _previous_audio.get_next_leaf_node()
	var _next_audio = get_next_audio_after(current_node)
	if _next_audio == null:
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(null)
	else:
		var _prev_leaf_naudio = _next_audio.get_previous_leaf_node()
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(_prev_leaf_naudio)
	
	return [_duration, _total_real_time]
	

# Play the group in pre-order
func play_preorden(__duration: float = 0.0, __total_real_time: float = 0.0, last_child: NodeController = null) -> void:
	_bus_core.current_node_changed.emit(_class_node)
	var index = _childrens.find(last_child)
		
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = get_parent()
		if parent != null and parent.has_method("play_preorden"):
			parent.play_preorden(__duration, __total_real_time, self)
		return
	
	var next_child_to_play = _childrens[index + 1]
	if next_child_to_play.has_method("play_preorden"):
		next_child_to_play.play_preorden(__duration, __total_real_time)


func play(__duration: float = 0.0, __total_real_time: float = 0.0) -> void:
	if _childrens.size() == 0:
		return
	
	if _childrens[0].has_method("play_preorden"):
		_childrens[0].play_preorden(__duration, __total_real_time)
	

## Called when the player seeked to a point before this group was played.
## The widgets should be reset to its initial state.
func reset() -> void:
	pass

## Called when the player seeked to a point after this group was played.
## The widgets should be set to its final state.
func skip_to_end() -> void:
	pass

static func instantiate(group: ClassNode, entities: Dictionary) -> NodeController:
	var _class: String = group.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	var controller: GroupController = CustomClassDB.instantiate(_class)
	controller.load_data(group, entities)
	controller._class_node = group
	return controller

func load_data(group: ClassGroup, entities: Dictionary) -> void:
	for children in group._childrens:
		var child_node: NodeController = NodeController.instantiate(children, entities)
		_childrens.append(child_node)
		add_child(child_node)
