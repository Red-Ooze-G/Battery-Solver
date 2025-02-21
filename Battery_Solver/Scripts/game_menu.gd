extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_skip_to_next_level_button_pressed() -> void:
	Util.user_data[Util.current_game_mode+"_level"] += 1
	get_tree().reload_current_scene()

func _on_skip_to_specific_level_button_pressed() -> void:
	var level_to_skip_to = ($CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/LineEdit.text).to_int()
	
	if level_to_skip_to:
		Util.user_data[Util.current_game_mode+"_level"] = level_to_skip_to
		get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_close_menu_button_pressed() -> void:
	visible = false
