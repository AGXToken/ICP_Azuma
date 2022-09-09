tool
extends EditorPlugin

var ic_settings
var ic_exporter


func _enter_tree():
	ic_settings = preload("res://addons/ic-gamekit/ic-settings.tscn").instance()
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, ic_settings)
	
	ic_exporter = preload("res://addons/ic-gamekit/ic-exporter.tscn").instance()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, ic_exporter)
	
	ic_settings.connect("ic_conector_enabled", ic_exporter, "_on_ICConnector_enabled")


func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, ic_settings)
	if ic_settings:
		ic_settings.free()
	
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, ic_exporter)
	if ic_exporter:
		ic_exporter.free()
