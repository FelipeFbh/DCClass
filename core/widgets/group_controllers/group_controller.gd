class_name GroupController
extends NodeController


var _childrens: Array[NodeController] = []
var _duration: float = 0
var _total_real_time: float = 0



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
		return parent.next(self)
	return null

# Return the previous controller in the group
# If there is no previous controller, it will return the previous controller in the parent group
func previous(current_node: NodeController) -> NodeController:
	var index = _childrens.find(current_node)
	if index > 0:
		return _childrens[index - 1]
	var parent = get_parent()
	if parent != null:
		return parent.previous(self)
	return null

# Return the next LeafController after current_node
func get_next_leaf_node(current_node: NodeController) -> LeafController:
	var next = next(current_node)
	if next == null:
		return null
	if next is LeafController:
		return next
	return next.get_first_leaf()

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
	var prev = previous(current_node)
	if prev == null:
		return null
	if prev is LeafController:
		return prev
	return (prev as GroupController).get_last_leaf()

# Return the next LeafController that is an audio
func get_next_audio_after(current_node: NodeController) -> LeafController:
	var leaf = get_next_leaf_node(current_node)
	while leaf != null and not leaf.is_audio():
		leaf = get_next_leaf_node(leaf)
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

	


func play(__duration: float = _duration, __total_real_time: float = _total_real_time) -> void:
	for child in _childrens:
		if child.has_method("play"):
			if child.has_method("is_audio") and child.is_audio():
				_duration = child.compute_duration()
				var next_leaf = get_next_leaf_node(child)
				var next_audio = get_next_audio_after(child)
				if next_audio == null:
					_total_real_time = next_leaf.compute_total_duration_between(null)
				else:
					var prev_leaf = next_audio.get_previous_leaf_node()
					_total_real_time = next_leaf.compute_total_duration_between(prev_leaf)
			await child.play(_duration, _total_real_time)
		else:
			push_error("Child " + child.get_class_name() + " does not have a play method.")
	#hide()

## Called when the player seeked to a point before this group was played.
## The widgets should be reset to its initial state.
func reset() -> void:
	pass

## Called when the player seeked to a point after this group was played.
## The widgets should be set to its final state.
func skip_to_end() -> void:
	pass

static func instantiate(group: ClassNode, entities: Array[Entity]) -> NodeController:
	var _class: String = group.get_class_name().replace("Class", "") + "Controller"
	assert(CustomClassDB.class_exists(_class), "Class " + _class + " does not exist.")
	var controller: GroupController = CustomClassDB.instantiate(_class)
	controller.load_data(group, entities)
	controller._class_node = group
	return controller

func load_data(group: ClassGroup, entities: Array[Entity]) -> void:
	for children in group._childrens:
		var child_node: NodeController = NodeController.instantiate(children, entities)
		_childrens.append(child_node)
		add_child(child_node)
