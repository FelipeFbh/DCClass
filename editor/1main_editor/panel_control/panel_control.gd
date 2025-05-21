# PanelControl.gd
class_name PanelControl
extends MarginContainer

@export var detach_window: PackedScene

@onready var bus : EditorEventBus

signal pen_toggled(active: bool)
signal request_detach

@onready var btn_pen     : Button  = %ButtonPen
@onready var btn_detach  : Button  = %ButtonDetach
@onready var tree_holder : Control = %EstructuraClase

var section_tree: Tree

func _ready() -> void:
	btn_pen.toggle_mode = true
	btn_pen.toggled.connect(_on_button_pen_toggled)
	btn_detach.pressed.connect(_on_button_detach_pressed)

	section_tree = Tree.new()
	section_tree.columns = 1
	section_tree.hide_root = true
	tree_holder.add_child(section_tree)

	# 3) Conecto la señal para rellenar las secciones
	bus = Engine.get_singleton("EditorSignals") as EditorEventBus

func _on_button_pen_toggled(active: bool) -> void:
	bus.pen_toggled.emit(active) 

func _on_button_detach_pressed() -> void:
	#emit_signal("request_detach")
	bus.request_detach.emit() 
	pass
	

func _on_class_sections_changed(sections: Array) -> void:
	_populate_section_tree(sections)

func _populate_section_tree(sections: Array) -> void:
	section_tree.clear()
	var root = section_tree.create_item() 
	for section in sections:
		var sec_item = root.create_child()
		sec_item.set_text(0, section.name)
		sec_item.set_collapsed(false)
		for slide in section.slides:
			var slide_item = sec_item.create_child()
			slide_item.set_text(0, slide.name)
			slide_item.set_metadata(0, slide)
			_populate_slide_content(slide_item, slide)

func _populate_slide_content(parent_item: TreeItem, slide: ClassNode) -> void:
	var content_root = slide.content_root
	if not is_instance_valid(content_root):
		return
	var content_item = parent_item.create_child()
	content_item.set_text(0, content_root.get_editor_name())
	content_item.set_metadata(0, content_root)
	_add_groups(content_item, content_root.groups)
	_add_entities(content_item, content_root.entities)

func _add_groups(parent_item: TreeItem, groups: Array[ClassGroup]) -> void:
	for group in groups:
		var group_item = parent_item.create_child()
		group_item.set_text(0, group.get_editor_name())
		group_item.set_metadata(0, group)
		_add_groups(group_item, group.groups)
		_add_entities(group_item, group.entities)
		print(group.entities)

func _add_entities(parent_item: TreeItem, entities: Array[EntityWrapper]) -> void:
	print(entities)
	for wrapper in entities:
		print(wrapper.serialize())
		var entity_item = parent_item.create_child()
		if is_instance_valid(wrapper.entity):
			entity_item.set_text(0, wrapper.entity.get_editor_name())
		else:
			entity_item.set_text(0, "EntityWrapper")
		entity_item.set_metadata(0, wrapper)
