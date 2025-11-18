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
func _populate_node(parent_item: TreeItem, node: ClassNode, entities: Dictionary, depth:=0, slide_order:=0) -> void:
	var item = tree_manager_index.create_item(parent_item)
	item.set_text(0, node.get_editor_name())
	item.set_metadata(0, node) # Store the node reference in the item metadata
	
	if node is ClassSlide:
		node = node as ClassSlide
		node._order = slide_order
		node._depth = depth
		# Increment depth and decrease order for children
		depth += 1
		slide_order = 0

	var child_slide_order = 0
	if node is ClassGroup or node is ClassSlide:
		for child in node._childrens:
			if child is ClassSlide: 
				_populate_node(item, child, entities, depth, child_slide_order)
				child_slide_order += 1
			else:
				_populate_node(item, child, entities, depth, slide_order)


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
