extends Control
@onready var timer: Timer = $Ani_Timer
var current_color_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Util.load_data()

func _on_timeout() -> void:
	if current_color_index == 14:
		current_color_index = 0
	$VBoxContainer/Uni_H/CenterContainer/Any_Battery.modulate = Util.color_hex[current_color_index]
	current_color_index += 1

func _on_universal_button_pressed() -> void:
	Util.current_game_mode = "universal"
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_similar_button_pressed() -> void:
	Util.current_game_mode = "similar"
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
