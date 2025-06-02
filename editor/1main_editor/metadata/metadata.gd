class_name MetadataEditor
extends Control

@export var metadata: ClassMetadata
var editor_signals: EditorEventBus
var parse_class: ParseClassEditor

@onready var btn_export_class : Button = %ExportButton

func _ready():
	%SaveButton.pressed.connect(save)
	btn_export_class.pressed.connect(export_class)


func _setup_metadata_class(index: ClassIndex):
	metadata = index.metadata
	_update()

## Update the editor to reflect the current metadata.
func _update():
	# Class Info
	%Name.text = metadata.name
	%Description.text = metadata.description
	%Course.text = metadata.course
	# Author info
	%AuthorName.text = metadata.author_name
	%AuthorDescription.text = metadata.author_description
	# File info
	%Version.text = metadata.file_version
	%Date.text = metadata.date.date
	%License.text = metadata.license
	%Editor.text = metadata.editor_version

## Save the metadata to the resource.
func save():
	var new_metadata = ClassMetadata.new()
	# Class Info
	new_metadata.name = %Name.text
	new_metadata.description = %Description.text
	new_metadata.course = %Course.text
	# Author info
	new_metadata.author_name = %AuthorName.text
	new_metadata.author_description = %AuthorDescription.text
	# File info
	new_metadata.file_version = %Version.text
	var date = Date.new()
	date.date = %Date.text
	new_metadata.date = date
	new_metadata.license = %License.text
	new_metadata.editor_version = %Editor.text
	# Save
	metadata = new_metadata
	parse_class.class_index.metadata = metadata


func export_class():
	var path: String = "user://tmp/class_editor/"
	var path_index : String = path + "index.json"
	var file := FileAccess.open(path_index, FileAccess.WRITE)
	file.store_string(JSON.stringify(parse_class.class_index.serialize(), "\t"))
	file.close()
	
	var zip_dest := "user://export_newclass.dcclass"
	var resultado := zip_folder(path, zip_dest)
	print("Export class path: ", zip_dest)


func zip_folder(source_dir: String, zip_path: String) -> Error:
	var zipper := ZIPPacker.new()
	var err := zipper.open(zip_path)
	if err != OK:
		push_error("Can't open the file to write:: %s (Error %d)" % [zip_path, err])
		return err

	_add_folder_to_zip(zipper, source_dir, "")
	zipper.close()
	return OK


func _add_folder_to_zip(zipper: ZIPPacker, current_dir: String, relative_path: String) -> void:
	for file_name in DirAccess.get_files_at(current_dir):
		var file_path := current_dir.path_join(file_name)
		var path_in_zip := relative_path + file_name
		
		var f := FileAccess.open(file_path, FileAccess.READ)
		if f == null:
			push_error("Can't open the file to read: %s" % file_path)
			continue
		var data := f.get_buffer(f.get_length())
		f.close()

		var err_start := zipper.start_file(path_in_zip)
		if err_start != OK:
			push_error("Error Zip: %s (Error %d)" % [path_in_zip, err_start])
			continue

		zipper.write_file(data)
		zipper.close_file()

	for subdir in DirAccess.get_directories_at(current_dir):
		var subdir_path := current_dir.path_join(subdir) + "/"
		var new_relative := relative_path + subdir + "/"

		_add_folder_to_zip(zipper, subdir_path, new_relative)
