tool
extends Control

const ic_project_folder = "ic-project"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_Button_pressed():
	$FileDialog.popup_centered()


func _on_ICConnector_enabled(toggled):
	$Button.visible = toggled


func _on_FileDialog_dir_selected(dir_path):
	convert_to_ic_project(dir_path)


func convert_to_ic_project(dir_path):
	var settings = ICSettingsUtilities.load_settings("res://addons/ic-gamekit/ic-settings.json")
	
	# Generate output directories.
	var dir = Directory.new()
	
	var ic_project_dir = dir_path + "/" + ic_project_folder
	if dir.dir_exists(ic_project_dir):
		remove_dir_recursively(ic_project_dir)
	dir.make_dir(ic_project_dir)
	
	var canister_dir = ic_project_dir + "/src/" + settings["CanisterName"]
	dir.make_dir_recursive(canister_dir)
	
	var canister_assets_dir = canister_dir + "/assets"
	var canister_src_dir = canister_dir + "/src"
	dir.make_dir(canister_assets_dir)
	dir.make_dir(canister_src_dir)
	
	# Loop the selected directory to copy the files.
	if dir.open(dir_path) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir(): # Skip ic_project directory itself.
				pass
			elif (file_name.get_extension() == "html"):
				dir.copy(dir_path + "/" + file_name, canister_src_dir + "/index.html")
			else:
				dir.copy(dir_path + "/" + file_name, canister_assets_dir + "/" + file_name)
			
			file_name = dir.get_next()
	else:
		print("Failed to access")
	
	generate_dfx_json(ic_project_dir, settings["CanisterName"])
	print("IC project generated")


func remove_dir_recursively(dir_path):
	var directory = Directory.new()
	
	# Loop the selected directory to copy the files.
	var res = directory.open(dir_path)
	if res == OK:
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				remove_dir_recursively(dir_path + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		
		directory.remove(dir_path)


func generate_dfx_json(dir_path, canister_name):
	var dfx_content = {
		"canisters" : {
			canister_name : {
				"frontend" : {
					"entrypoint": "src/" + canister_name + "/src/index.html"
				},
				"source" : [
					"src/" + canister_name + "/assets",
					"src/" + canister_name + "/src"
				],
				"type" : "assets"
			}
		},
		"version" : 1
	}
	
	var file = File.new();
	file.open(dir_path + "/dfx.json", File.WRITE)
	var json_string = JSON.print(dfx_content, "  ");
	file.store_string(json_string)
	file.close()
