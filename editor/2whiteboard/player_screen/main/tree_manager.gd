class_name TreeManagerEditor
extends Resource


signal node_selected(class_node)

var tree: Tree

func _init():
	tree = Tree.new()
	tree.name = "IndexTree"
	tree.hide_root = true
	tree.columns = 1
	tree.scroll_horizontal_enabled = true

func build(root_group: ClassGroup, entities: Array[Entity]) -> Tree:
	tree.clear()
	var root_item = tree.create_item()
	_populate_node(root_item, root_group, entities)
	return tree

func _populate_node(parent_item: TreeItem, node: ClassNode, entities: Array[Entity]) -> void:
	var item = tree.create_item(parent_item)
	item.set_text(0, node.get_editor_name(entities))
	item.set_metadata(0, "node")
	if node is ClassGroup:
		for child in node._childrens:
			_populate_node(item, child, entities)

func _on_item_selected():
	var selected = tree.get_selected()
	if selected:
		var node = selected.get_metadata(0)
		emit_signal("node_selected", node)
