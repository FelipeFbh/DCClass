@tool
class_name Entity
extends Resource

var entity_id
@export var duration: float = 0.0

## Base class for Entity types

## Returns the id of this entity.
func get_entity_id():
	return entity_id

## Returns the name of the class.
func get_class_name() -> String:
	return "Entity"

## Returns the name of this entity.
func get_editor_name() -> String:
	return "Unnamed entity"

## Returns a dictionary representation of this entity.
func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"entity_type": get_class_name()
	}

## Returns a new instance of this entity type from the given dictionary.
static func deserialize(data: Dictionary) -> Entity:
	assert(CustomClassDB.class_exists(data["entity_type"]), "Entity type does not exist: " + data["entity_type"])
	var instance = CustomClassDB.instantiate(data["entity_type"])
	instance.entity_id = data["entity_id"]
	instance.load_data(data)
	return instance

## Loads data from a dictionary into this entity.
func load_data(_data: Dictionary) -> void:
	pass

func copy_tmp() -> Entity:
	var new_entity: Entity = CustomClassDB.instantiate(get_class_name())
	new_entity.load_data(serialize())
	return new_entity

## Deletes this entity.
func self_delete() -> void:
	pass

func tmp_to_persistent() -> void:
	pass