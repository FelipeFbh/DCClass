@tool
# 1. class name: fill the class name
class_name ClassIndex
extends Resource

# 2. docs: use docstring (##) to generate docs for this file
## The main file of a class index

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var metadata: ClassMetadata
@export var entities: Dictionary = {}
@export var tree_structure: ClassNode

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here


# 10. init virtual methods: define _init, _enter_tree and _ready mothods here


# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here


func serialize() -> Dictionary:
	var data = {
		"metadata": metadata.serialize(),
		"entities": entities.values().map(func(e): return e.serialize()),
		"tree_structure": tree_structure.serialize(),
	}
	return data

static func deserialize(data: Dictionary) -> ClassIndex:
	var instance = ClassIndex.new()
	instance.metadata = ClassMetadata.deserialize(data["metadata"])

	for entity_data in data["entities"]:
		var entity = Entity.deserialize(entity_data)
		instance.entities[entity.get_entity_id()] = entity
	
	ClassLeaf.entities = instance.entities
	instance.tree_structure = ClassNode.deserialize(data["tree_structure"])
	return instance

# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
