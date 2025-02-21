extends Node2D

var test_tubes_cache : Dictionary

const TEST_TUBE_BLUEPRINT = preload("res://Scenes/test_tube.tscn")

var all_testtubes : Array[TestTube]

var debug_amount_rows = 2
var test_tube_amount : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Util.move_history = []
	Util.reset_score()
	var level_type : String = Util.current_game_mode + "_level"
	var level_number = Util.user_data[level_type]
	$Level_Label.text = str(level_number) + ' - ' + Util.current_game_mode
	seed(level_number)
	var top_range : int = 8 if Util.current_game_mode == "similar" else 14
	test_tube_amount = randi_range(5,top_range)
	instantiate_test_tubes(test_tube_amount)

func instantiate_test_tubes(amount : int) -> void:
	var amount_with_empties : int = amount + 1 if Util.current_game_mode == "universal" else amount + 2
	var row_count : int = 1
	
	if amount_with_empties > 8:
		row_count = 3
	elif amount_with_empties > 4:
		row_count = 2

	var row_index : int = 0

	for i in range(amount_with_empties):

		#Determine a color and spawn the test tube there
		instantiate_test_tube_at("VBoxContainer/HBox-" + str(row_index))

		#If the next row is more than the amount of rows we want, circle back to the first row
		if row_index == row_count - 1:
			row_index = 0
		#If next row is allowed and desired, go to it
		else:
			row_index += 1
		
		#Once we hit the index of the last full test tube, we scramble them, before we add the empty test tubes
		if i == amount - 1:
			scramble()

func instantiate_test_tube_at(destination_node_path : String) -> void:
		var instance = TEST_TUBE_BLUEPRINT.instantiate()
		instance.connect("_test_tube_selected", store_test_tube_data)
		var parent_node = get_node(destination_node_path)
		parent_node.add_child(instance)
		all_testtubes.append(instance)

func scramble() -> void:
	var color_container : Array[int]
	for i in range(test_tube_amount):
		for _x in range(4):
			color_container.append(i)
	color_container.shuffle()

	for test_tube in all_testtubes:
		for _x in range(4):
			var test_tube_color = color_container.pop_front()
			test_tube.receive_fluid(1, test_tube_color)

func _unhandled_input(event: InputEvent) -> void:

		if event.is_action_pressed("ui_accept"):
			return
			for i in range(3):
				var parent_node = get_node("VBoxContainer/HBox-" + str(i))
				var child_nodes = parent_node.get_children()
				for child in child_nodes:
					child.queue_free()
			instantiate_test_tubes(debug_amount_rows)
			debug_amount_rows += 1

func store_test_tube_data(test_tube : TestTube) -> void:

	if not test_tubes_cache.has("selected"):
		#If selection is possible, then select it
		if test_tube.select_test_tube():
			test_tubes_cache["selected"]  = test_tube
			$SFX/Linger.play()
	else:
		#event deselect_test_tube(s)
		if test_tubes_cache["selected"] == test_tube:
			test_tube.deselect_test_tube()
			$SFX/Linger.stop()
			test_tubes_cache.erase("selected")
		else:
			var move_amount : int = test_tubes_cache["selected"].transfer_fluid_to(test_tube)
			if move_amount > 0:
				var move = FluidMovement.new()
				move.origin_test_tube = test_tubes_cache["selected"]
				move.destination_test_tube = test_tube
				move.fluid_move_amount = move_amount
				Util.move_history.append(move)
				
			test_tubes_cache["selected"].deselect_test_tube()
			$SFX/Linger.stop()
			$SFX/Transfer.play()
			test_tubes_cache.erase("selected")

	if Util.score == test_tube_amount:
		Util.increment_level()
		$"LevelEnd-Assets".visible = true

func _on_settings_opened() -> void:
	$Game_Menu.visible = true


func _on_level_skip_pressed() -> void:
	var level_to_skip_to = ($LevelSkip_Menu/TextEdit.text).to_int()
	
	if level_to_skip_to:
		Util.user_data[Util.current_game_mode+"_level"] = level_to_skip_to
		get_tree().reload_current_scene()

func _on_next_level_press() -> void:
	get_tree().reload_current_scene()

func _on_undo_button_pressed() -> void:

	if test_tubes_cache.has("selected"):
		test_tubes_cache["selected"].deselect_test_tube()
		$SFX/Linger.stop()
		test_tubes_cache.erase("selected")
	if Util.move_history.size() == 0:
		return

	var last_move = Util.move_history.pop_back()
	if last_move.destination_test_tube.check_for_completion():
		Util.score -= 2
	last_move.destination_test_tube.move_fluid_without_rules(last_move.origin_test_tube, last_move.fluid_move_amount)
