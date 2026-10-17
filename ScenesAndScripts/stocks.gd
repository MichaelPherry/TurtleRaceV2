extends Control

#var rounds = 2
#var round_results = {1: ["playa_id", "cpu1_id", "cpu2_id", "cpu3_id"], 2: ["cpu1_id", "playa_id", "cpu3_id", "cpu2_id"]}
@export var draw_speed: float = 0.5

@onready var axis = $Axis
@onready var graph_area = $GraphArea
@onready var line1 = $GraphArea/Stock1Line
@onready var line2 = $GraphArea/Stock2Line
@onready var line3 = $GraphArea/Stock3Line
@onready var line4 = $GraphArea/Stock4Line

var draw_progress = 0.0
var is_drawing = false
var max_stock_value
var point_height
var point_width

var curr_first
var curr_second
var curr_third
var curr_fourth
var pre_first
var pre_second
var pre_third
var pre_fourth
var pre_pre_first
var pre_pre_second
var pre_pre_third
var pre_pre_fourth

var stock1_value
var stock1_history
var stock2_value
var stock2_history
var stock3_value
var stock3_history
var stock4_value
var stock4_history

func _ready():
	#var line = $GraphArea/work
	#line.default_color = Color.YELLOW
	#line.width = 6.0
	#line.points = PackedVector2Array([
	#Vector2(50, 50),
	#Vector2(250, 150)
	#])
	stock1_value = 4
	stock1_history = []
	stock2_value = 4
	stock2_history = []
	stock3_value = 4
	stock3_history = []
	stock4_value = 4
	stock4_history = []

	max_stock_value = 0
	
	curr_first = null
	curr_second = null
	curr_third = null
	curr_fourth = null
	pre_first = null
	pre_second = null
	pre_third = null
	pre_fourth = null
	pre_pre_first = null
	pre_pre_second = null
	pre_pre_third = null
	pre_pre_fourth = null
	
	stock_value_calc()

func _process(delta):
	var temp = axis.get_children()
	

func stock_value_calc():
	for round in range(1, Inventory.rounds + 1):
		for placement in range(Inventory.round_results[str(round)].size()):
			var race_result = Inventory.round_results[str(round)]
			match placement:
				0:
					curr_first = race_result[placement]
				1:
					curr_second = race_result[placement]
				2:
					curr_third = race_result[placement]
				3:
					curr_fourth = race_result[placement]
		if round >= 3:
			if curr_first == pre_first and pre_first == pre_pre_first:
				stock_evaluation(curr_first, 4)
			else:
				stock_evaluation(curr_first, 2)
			if curr_second == pre_second and pre_second == pre_pre_second:
				stock_evaluation(curr_second, 2)
			else:
				stock_evaluation(curr_second, 1)
			stock_evaluation(curr_third, 0)
			if curr_fourth == pre_fourth and pre_fourth == pre_pre_fourth:
				stock_evaluation(curr_fourth, -2)
			else:
				stock_evaluation(curr_second, -1)
		else:
			stock_evaluation(curr_first, 2)
			stock_evaluation(curr_second, 1)
			stock_evaluation(curr_third, 0)
			stock_evaluation(curr_fourth, -1)
		
		stock1_history.append(stock1_value)
		stock2_history.append(stock2_value)
		stock3_history.append(stock3_value)
		stock4_history.append(stock4_value)
		if stock1_value > max_stock_value:
			max_stock_value = stock1_value
		if stock2_value > max_stock_value:
			max_stock_value = stock2_value
		if stock3_value > max_stock_value:
			max_stock_value = stock3_value
		if stock4_value > max_stock_value:
			max_stock_value = stock4_value
		
		if round > 2:
			pre_pre_first = pre_first
			pre_pre_second = pre_pre_second
			pre_pre_third = pre_third
			pre_pre_fourth = pre_fourth
		pre_first = curr_first
		pre_second = curr_second
		pre_third = curr_third
		pre_fourth = curr_fourth
		
	draw_x_lines()
	draw_y_lines()
	draw_graph(stock1_value, stock1_history, line1)
	draw_graph(stock2_value, stock2_history, line2)
	draw_graph(stock3_value, stock3_history, line3)
	draw_graph(stock4_value, stock4_history, line4)

func draw_graph(stock, history, stock_line):
	var graph_size = graph_area.size
	#var point_width = 160
	#var point_height = 800
	
	var points = PackedVector2Array()
	for round in range(history.size()):
		var x = point_width * round
		var y = 840 - ((point_height / 4) * history[round])
		points.append(Vector2(x,y))
	stock_line.points = points
	var temp = 0
	

func stock_evaluation(sid, value_chage):
	match sid:
		Inventory.stock1_turt:
			stock1_value += value_chage
			if stock1_value < 1:
				stock1_value = 1
		Inventory.stock2_turt:
			stock2_value += value_chage
			if stock2_value < 1:
				stock2_value = 1
		Inventory.stock3_turt:
			stock3_value += value_chage
			if stock3_value < 1:
				stock3_value = 1
		Inventory.stock4_turt:
			stock4_value += value_chage
			if stock4_value < 1:
				stock4_value = 1


func draw_x_lines():
	point_height = min(100, graph_area.size.y / max_stock_value)
	
	var counter = 1
	while counter * point_height < graph_area.size.y:
		var horiz_line = Line2D.new()
		var price_label = Label.new()
		horiz_line.width = 2
		horiz_line.default_color = Color.BLACK
		horiz_line.points = PackedVector2Array([Vector2(160, 940 - (counter * point_height)), Vector2(1740, 940 - (counter * point_height))])
		price_label.text = str(counter * 5)
		price_label.add_theme_font_size_override("font_size", 36)
		price_label.add_theme_color_override("font_color", Color.BLACK)
		price_label.position = Vector2(100, 940 - (counter * point_height) - 20)
		axis.add_child(horiz_line)
		axis.add_child(price_label)
		counter += 1 

func draw_y_lines():
	point_width = min(200, graph_area.size.x / Inventory.rounds)
	
	var counter = 1
	while counter * point_width <= graph_area.size.x:
		var vert_line = Line2D.new()
		var round_label = Label.new()
		vert_line.width = 2
		vert_line.default_color = Color.BLACK
		vert_line.points = PackedVector2Array([Vector2((counter * point_width) - 40, 140), Vector2((counter * point_width) - 40, 940)])
		round_label.text = str(counter)
		round_label.add_theme_font_size_override("font_size", 36)
		round_label.add_theme_color_override("font_color", Color.BLACK)
		round_label.position = Vector2((counter * point_width) - 40 - 10, 960)
		axis.add_child(vert_line)
		axis.add_child(round_label)
		counter += 1
	var temp = 0

func _on_shop_pressed() -> void:
	for child in axis.get_children():
		child.queue_free()
	get_tree().change_scene_to_file("res://ScenesAndScripts/shop.tscn")
