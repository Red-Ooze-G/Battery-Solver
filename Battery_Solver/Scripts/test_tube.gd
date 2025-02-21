extends Control
class_name TestTube

@export var fluids : Array[Util.FLUID_COLOR]# = [Util.FLUID_COLOR.RED]

signal _test_tube_selected(TestTube)
var is_movable : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.focus_mode = Control.FOCUS_NONE
	update_visual()

func update_visual() -> void:
	
	#var i : int = 0
	var fluid_amount : int = fluids.size()
	
	for i in range(4):
		#print(i)
	#	for fluid : Util.FLUID_COLOR in fluids:
		var layer : ColorRect = get_node( ("VBoxContainer/Layer_" + str(i)) )
		#layer_color = fluids.get(i)
		if fluid_amount >= (i + 1):
			layer.visible = true
			layer.color = Util.color_hex[fluids[i]]
		else:
			layer.visible = false


func transfer_fluid_to(destination_tube : TestTube, override_amount = null) -> int:
	#possibly redundant ID:001/1
	
	var fluid_amount = fluids.size()

	#Check if the test tube has any fluid that it can even transfer
	if fluid_amount <= 0 or not is_movable:
		print("early return")
		return 0
	
	var outgoing_fluid_amount : int = 1
	var top_fluid_color : Util.FLUID_COLOR = fluids[-1]

	if destination_tube.fluids.size() != 0 and Util.current_game_mode == "similar":
		var top_dest_fluid_color : Util.FLUID_COLOR = destination_tube.fluids[-1]
		if top_fluid_color != top_dest_fluid_color:
			return 0

	#If no override, then figure out how much liquid can be sent
	if fluid_amount > 1:
		
		#From the penultimate, work backwards to figure out how much liquid of matching color exists
		for i in range( -2, (-fluid_amount - 1), -1):
			if top_fluid_color == fluids[i]:
				outgoing_fluid_amount += 1
			else:
				break
		
		#If override is set and its value is smaller, then limit outgoing to that amount
		if override_amount and override_amount < outgoing_fluid_amount:
			outgoing_fluid_amount = override_amount
	
	#Transfer the fluid, the method returns the amount of fluid it used
	var transfered_fluid_amount : int = destination_tube.receive_fluid(outgoing_fluid_amount, top_fluid_color)
	
	
	for i in range(transfered_fluid_amount):
		fluids.pop_back()
	update_visual()
	
	return transfered_fluid_amount

#Used to undo moves, so checking if it violates rule is unnecessary
func move_fluid_without_rules(destination_tube : TestTube, fluid_move_amount : int) -> void:
	var top_fluid_color : Util.FLUID_COLOR = fluids[-1]

	#Transfer the fluid, the method returns the amount of fluid it used
	var transfered_fluid_amount : int = destination_tube.receive_fluid(fluid_move_amount, top_fluid_color)

	for i in range(transfered_fluid_amount):
		fluids.pop_back()
	update_visual()

#return the amount of fluid it used
func receive_fluid(incoming_fluid_amount : int, fluid_color : Util.FLUID_COLOR) -> int:
	var fluid_space_available : int = 4 - fluids.size()

	#If there's no space, receive nothing (i.e. 0)
	if fluid_space_available == 0:
		return 0

	var amount_received : int

	#If we have enough space available, receive everything
	if fluid_space_available >= incoming_fluid_amount:
		amount_received = incoming_fluid_amount

	#If we have limited space, receive only what we can
	else:
		amount_received = fluid_space_available

	#Add the amount received to the test tube
	for i in range(amount_received):
		fluids.append(fluid_color)

	#Update UI
	update_visual()
	check_for_completion()

	#Tell the receiver how much of the sent fluid was received
	return amount_received


func check_for_completion() -> bool:
	if fluids.size() != 4:
		is_movable = true
		return false
	var primary_fluid = fluids[0]
	for fluid in fluids:
		if primary_fluid != fluid:
			is_movable = true
			return false
	is_movable = false
	Util.score += 1
	return true

#Send reference to itself to parent scene
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pass#emit_signal("_test_tube_selected", self)


func _on_mouse_entered() -> void:
	print("enter")


func _on_mouse_exited() -> void:
	print("exot")

func select_test_tube() -> bool:
	if fluids.size() > 0 and is_movable:
		$Spark.visible = true
		$Spark.modulate = Util.color_hex[fluids[-1]]
		$Electricity.visible = true
		$Electricity.modulate = Util.color_hex[fluids[-1]]
		return true
	return false

func exchange_fluids(target_test_tube : TestTube, layer_amount : int) -> void:
	var test_tube_fullness : int = fluids.size()
	var target_fullness : int = target_test_tube.fluids.size()
	
	if test_tube_fullness < layer_amount or target_fullness < layer_amount:
		return
	
	var alternate_point : int = test_tube_fullness - layer_amount
	var target_alt_point : int = target_fullness - layer_amount
	
	var transfer_test_tube : Array[Util.FLUID_COLOR]

	#Keeps its intial, but takes the target's end
	for i in range(test_tube_fullness):
		if i < alternate_point:
			transfer_test_tube.append(fluids[i])
		else:
			transfer_test_tube.append(target_test_tube.fluids[i])

	for i in range(target_fullness):
		if i >= target_alt_point:
			target_test_tube.fluids[i] = fluids[i]
	
	fluids = transfer_test_tube
	update_visual()
	target_test_tube.update_visual()
	#currently can only transfer if test tubes contain same amount, otherwise a crash is sure to occur


func deselect_test_tube() -> void:
	$Spark.visible = false
	$Electricity.visible = false

func _on_button_pressed() -> void:
	emit_signal("_test_tube_selected", self)
