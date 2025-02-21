extends Node

var score : int = 0
var current_game_mode = "universal"
var is_data_loaded : bool = false
var move_history : Array[FluidMovement]

var user_data : Dictionary = {
	"universal_level" : 1,
	"similar_level" : 1
}

enum FLUID_COLOR{RED, ORANGE, GREEN, PURPLE, BLUE, YELLOW, CYAN, BROWN, WHITE, BLACK, LIME, MIDNIGHT, PINK, BABY_PURPLE}
var color_hex : Dictionary = {
	Util.FLUID_COLOR.RED : Color.html("CD1B0F"),
	Util.FLUID_COLOR.ORANGE : Color.html("FA7D00"),
	Util.FLUID_COLOR.GREEN : Color.html("0C550C"),
	Util.FLUID_COLOR.LIME : Color.html("4CFF00"),
	Util.FLUID_COLOR.PINK : Color.html("FF7F7F"),
	Util.FLUID_COLOR.BABY_PURPLE : Color.html("867FFF"),
	Util.FLUID_COLOR.PURPLE : Color.html("9152A1"),
	Util.FLUID_COLOR.MIDNIGHT : Color.html("46007F"),
	Util.FLUID_COLOR.BLUE : Color.html("003AB2"),
	Util.FLUID_COLOR.YELLOW : Color.html("FFD800"),
	Util.FLUID_COLOR.CYAN : Color.html("00FFFF"),
	Util.FLUID_COLOR.BROWN : Color.html("724545"),
	Util.FLUID_COLOR.WHITE : Color.html("A0A0A0"),
	Util.FLUID_COLOR.BLACK : Color.html("1E1E1E")
}

var save_path := "user://level.ini"

func load_data() -> void:
	if is_data_loaded:
		return
	var config_file := ConfigFile.new()
	var error := config_file.load(save_path)

	if error:
		print("An error happened while loading data: ", error)
		return

	user_data["universal_level"] = config_file.get_value("Global", "universal_level", 1)
	user_data["similar_level"] = config_file.get_value("Global", "similar_level", 1)

	is_data_loaded = true

func save_data() -> void:
	var config_file := ConfigFile.new()
	var save_name = current_game_mode
	var level : int = user_data[current_game_mode+"_level"]
	
	print("save name is: " + str(save_name) + ". and level is: " + str(level))

	var error := config_file.load(save_path)

	if error:
		print("An error happened while loading data: ", error)
		return

	config_file.set_value("Global", current_game_mode+"_level", level)
	error = config_file.save(save_path)

	if error:
		print("An error happened while saving data: ", error)

func reset_score() -> void:
	score = 0

func increment_level() -> void:
	user_data[current_game_mode+"_level"] += 1
	save_data()
