# parse.gd
extends Node

# Variables de configuración y resultado del parseo
var file: String = ""
@export var class_index: ClassIndex
var entities: Array = []
var slide_count: int = 0
var entry_point: SlideNode = null
var section_manager: SectionManager = null
var zip_file: ZIPReader = null

# Variables para el cómputo de duración
var total_duration: float = 0.0
var timestamps: Array = []

# -----------------------------------------------------------------
# Función que parsea la persistencia a partir de un archivo ZIP.
# Usa 'PersistenceEditor.clase_path' si no se configura 'file'.
# -----------------------------------------------------------------
func parse_persistence() -> bool:
	zip_file = ZIPReader.new()
	
	if file == null or file.is_empty():
		file = PersistenceEditor.clase_path
	
	print("File a parsear: " + file)
	
	if file == null or file.is_empty():
		push_error("Error: file not set")
		return false
	
	var err = zip_file.open(file)
	if err != OK:
		push_error("Error %d opening file: " % err)
		return false
	
	if not zip_file.file_exists("index.json"):
		push_error("Error: index.json not found in zip file")
		return false
	
	var index_string = zip_file.read_file("index.json").get_string_from_utf8()
	var index = JSON.parse_string(index_string)
	if index == null or typeof(index) != TYPE_DICTIONARY:
		push_error("Error: index no es un diccionario válido")
		return false
	
	Widget.zip_file = zip_file
	class_index = ClassIndex.deserialize(index)
	PersistenceEditor.clase_index = class_index
	
	var bus = Engine.get_singleton(&"EditorSignals") as EditorEventBus
	bus.class_index_changed.emit(class_index)
	bus.class_script_changed.emit(class_index.class_script)
	
	return class_index != null

# -----------------------------------------------------------------
# Instancia la jerarquía 2D a partir del class_index parseado.
# Devuelve un Node2D con las secciones y slides.
# -----------------------------------------------------------------
func instantiate_content() -> Node2D:
	section_manager = SectionManager.new()
	entities = class_index.entities
	slide_count = 0
	entry_point = null
	
	var root_2d = Node2D.new()
	var section_y_position: float = 0.0
	var whiteboard_size: Vector2 = ProjectSettings.get_setting("display/whiteboard/size") as Vector2
	print(whiteboard_size)
	
	for section in class_index.sections:
		var section_node: Node2D = instantiate_section(section, whiteboard_size)
		section_node.position.y = section_y_position
		section_y_position += whiteboard_size.y
		root_2d.add_child(section_node)
	
	return root_2d

# -----------------------------------------------------------------
# Función auxiliar: instancia una sección.
# -----------------------------------------------------------------
func instantiate_section(section: ClassNode, whiteboard_size: Vector2) -> Node2D:
	var node: Node2D = Node2D.new()
	var section_tree_item = section_manager.register_section(section.name)
	
	var slide_x_position: float = 0.0
	for slide in section.slides:
		var slide_node: SlideNode = instantiate_slide(slide)
		var slide_tree_item = section_manager.register_slide(section_tree_item, slide_node.name)
		slide_node.tree_item = slide_tree_item
		slide_node.absolute_slide_id = slide_count
		slide_node.position.x = slide_x_position
		slide_x_position += whiteboard_size.x
		slide_count += 1
		node.add_child(slide_node)
	
	if node.get_child_count() > 0:
		section_tree_item.set_metadata(0, node.get_child(0))
	
	return node

# -----------------------------------------------------------------
# Función auxiliar: instancia una slide.
# -----------------------------------------------------------------
func instantiate_slide(slide: ClassNode) -> SlideNode:
	var node: SlideNode = SlideNode.new()
	node.name = slide.name
	var group: GroupController = GroupController.instantiate(slide.content_root, entities)
	
	if not is_instance_valid(entry_point):
		entry_point = node
	
	node.add_child(group)
	return node

# -----------------------------------------------------------------
# Recorre el contenido generado y asigna tiempos para la reproducción.
# Calcula la duración total y establece un timestamp a cada GroupController.
# -----------------------------------------------------------------
func compute_duration(root_node: Node2D) -> void:
	total_duration = 0.0
	timestamps.clear()
	
	for section in root_node.get_children():
		for slide in section.get_children():
			var group = slide.get_child(0) as GroupController
			group.timestamp = total_duration
			timestamps.append(group)
			total_duration += group.compute_duration()

# -----------------------------------------------------------------
# Inicia la reproducción llamando al 'play' del primer slide.
# -----------------------------------------------------------------
func play():
	if not is_instance_valid(entry_point):
		push_error("Error playing content: entry_point is not valid")
		return
	entry_point.play()
