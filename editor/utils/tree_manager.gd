class_name TreeManagerEditor
extends Tree

var tree_manager_index: Tree

# Build the index tree following the structure of the classGroup.
func build(root_group: ClassGroup, entities: Dictionary) -> Tree:
	tree_manager_index.clear()
	var root_item = tree_manager_index.create_item()
	_populate_node(root_item, root_group, entities)
	return tree_manager_index

# Populate the tree with nodes from the class structure.
func _populate_node(parent_item: TreeItem, node: ClassNode, entities: Dictionary) -> void:
	var item = tree_manager_index.create_item(parent_item)
	item.set_text(0, node.get_editor_name())
	item.set_metadata(0, node) # Store the node reference in the item metadata
	if node is ClassGroup:
		for child in node._childrens:
			_populate_node(item, child, entities)

# Reset the colors of all items in the tree to a default color.
func reset_colors():
	var root = tree_manager_index.get_root()
	if root == null:
		return
	var item = root
	while item:
		item.set_custom_color(0, Color.GRAY)
		item = item.get_next_visible()

# Find a TreeItem by its associated ClassNode.
func find_item_by_node(target: ClassNode) -> TreeItem:
	var root = tree_manager_index.get_root()
	if root == null:
		return null
	return _find_item_recursive(root, target)

# Recursively search for a TreeItem that matches the target ClassNode.
func _find_item_recursive(item: TreeItem, target: ClassNode) -> TreeItem:
	if item.get_metadata(0) == target:
		return item
	var child = item.get_first_child()
	while child:
		var found = _find_item_recursive(child, target)
		if found:
			return found
		child = child.get_next()
	return null



#region ¡Experimental
func get_next_leaf_item(current_node: ClassNode) -> TreeItem:
	var current_item = find_item_by_node(current_node)
	if current_item == null:
		return null
	var next_item = current_item.get_next_visible()
	while next_item:
		var node = next_item.get_metadata(0)
		if node is ClassLeaf:
			return next_item
		next_item = next_item.get_next_visible()
	return null


func get_previous_leaf_item(current_node: ClassNode) -> TreeItem:
	var current_item = find_item_by_node(current_node)
	if current_item == null:
		return null
	var prev_item = current_item.get_prev_visible()
	while prev_item:
		var node = prev_item.get_metadata(0)
		if node is ClassLeaf:
			return prev_item
		prev_item = prev_item.get_prev_visible()
	return null
#endregion
