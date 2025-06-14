class_name GroupController
extends NodeController


var _childrens: Array[ClassNode] = []

# Returns the index of the controller in _childrens
func _index_of(current_node: NodeController) -> int:
	if current_node == null:
		return -1
	return _childrens.find(current_node._class_node)


func _setup(instance : ClassGroup):
	_class_node = instance
	_childrens = instance._childrens


# Play the group in pre-order
func play_tree(__duration: float = 0.0, __total_real_time: float = 0.0, last_child: NodeController = null) -> void:
	var index = _index_of(last_child)
		
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller()
		if parent != null:
			parent.play_tree(__duration, __total_real_time, self)
			return
		_bus_core.tree_play_finished.emit()
		return
	
	var next_child_to_play = _childrens[index + 1]._node_controller
	next_child_to_play.play_tree(__duration, __total_real_time, self)


func play_seek(last_child: NodeController = null) -> void:
	var index = _index_of(last_child)
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller()
		if parent != null:
			parent.play_seek(self)
		return
	
	var next_child_to_play = _childrens[index + 1]._node_controller
	next_child_to_play.play_seek(self)

func seek(node_seek: NodeController, last_child: NodeController = null) -> void:
	var current: NodeController = last_child
	var current_node = [self, last_child]
	while current != null:
		current.skip_to_end()
		if current == node_seek:
			return
		current_node = current.get_next(current_node)
		current = current_node[0]
	return


func skip_to_end():
	pass

func self_delete() -> void:
	queue_free()

#region Tree Navigation

# Return the next NodeController after __current_node
func get_next(__current_node: Array) -> Array:
	var current_node = __current_node[0]
	var last_child = __current_node[1]
	var index = current_node._index_of(last_child)
		
	if current_node._childrens.size() == 0 or index + 1 == current_node._childrens.size():
		var parent = current_node._class_node.get_parent_controller()
		if parent != null:
			return [parent, current_node]
		return [null, null]
	
	var next_child = current_node._childrens[index + 1]._node_controller
	return [next_child, null]


# Return the previous LeafController before last_child
func get_previous(__current_node: Array) -> Array:
	var current_node = __current_node[0]
	var last_child = __current_node[1]
	var index = current_node._index_of(last_child)
	
	if index == -1:
		index = current_node._childrens.size()
	
	if current_node._childrens.size() == 0 or index - 1 <= -1:
		var parent = current_node._class_node.get_parent_controller()
		if parent != null:
			return [parent, current_node]
		return [null, null]

	var prev_child = current_node._childrens[index - 1]._node_controller
	return [prev_child, null]


# Return the next LeafController after last_child
func get_next_leaf(last_child: NodeController) -> LeafController:
	var current_node = self
	var next_child = get_next([current_node, last_child])
	while next_child[0] != null:
		if next_child[0] is LeafController:
			return next_child[0]
		next_child = next_child[0].get_next([next_child[0], next_child[1]])
	return null


# Return the previous LeafController before last_child
func get_previous_leaf(last_child: NodeController) -> LeafController:
	var current_node = self
	var prev_child = get_previous([current_node, last_child])
	while prev_child[0] != null:
		if prev_child[0] is LeafController:
			return prev_child[0]
		prev_child = prev_child[0].get_previous([prev_child[0], prev_child[1]])
	return null

#endregion


#region Playing Tree Utilities

# Return the last ClearEntity before the current node
func get_last_clear() -> LeafController:
	var last_children
	if _childrens.is_empty():
		last_children = self
	else:
		last_children = _childrens[0]._node_controller
	
	var prev = get_previous_leaf(last_children)
	while prev != null and not (prev._class_node.entity is ClearEntity):
		prev = prev.get_previous_leaf(prev)
	return prev

# Return the next LeafController that is an audio
func get_next_audio(current_node: NodeController) -> LeafController:
	var leaf = get_next_leaf(current_node)
	while leaf != null and not leaf.is_audio():
		leaf = get_next_leaf(leaf)
	return leaf

# Return the previous LeafController that is an audio
func get_previous_audio(current_node: NodeController) -> LeafController:
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
		_previous_audio = get_previous_audio(current_node)
		_duration = _previous_audio.compute_duration()
	
	var _next_leaf_paudio = _previous_audio.get_next_leaf()
	var _next_audio = get_next_audio(current_node)
	if _next_audio == null:
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(null)
	else:
		var _prev_leaf_naudio = _next_audio.get_previous_leaf(self)
		_total_real_time = _next_leaf_paudio.compute_total_duration_between(_prev_leaf_naudio)
	
	return [_duration, _total_real_time]

#endregion


# Warning !!! Recursive calls can overflow the stack!
func recursive_seek(node_seek: NodeController, last_child: NodeController = null) -> void:
	if node_seek == self:
		return

	var index = _index_of(last_child)
		
	if _childrens.size() == 0 or index + 1 == _childrens.size():
		var parent = _class_node.get_parent_controller()
		if parent != null:
			parent.recursive_seek(node_seek, self)
		return
	
	var next_child = _childrens[index + 1]._node_controller
	next_child.recursive_seek(node_seek, self)
