extends Control

#var rounds = 2
#var round_results = {1: ["playa_id", "cpu1_id", "cpu2_id", "cpu3_id"], 2: ["cpu1_id", "playa_id", "cpu3_id", "cpu2_id"]}
@export var draw_speed: float = 3.0

@onready var axis = $Axis
@onready var graph_tooltip = $GraphToolTip
@onready var graph_area = $GraphArea
@onready var line1 = $Stock1Line
@onready var line2 = $Stock2Line
@onready var line3 = $Stock3Line
@onready var line4 = $Stock4Line

var yaxis_start = -1200
var yaxis_max = 239
var xaxis_start = 500
var xaxis_max = -500

var player_lines

var vert_line_amt = 6
var horiz_line_amt = 8

var draw_progress = 0.0
var is_drawing = false
var line_width_value
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
var stock1_adj_history
var stock1_grid_points
var stock2_value
var stock2_history
var stock2_adj_history
var stock2_grid_points
var stock3_value
var stock3_history
var stock3_adj_history
var stock3_grid_points
var stock4_value
var stock4_history
var stock4_adj_history
var stock4_grid_points
var all_grid_points

var axi
var animation_progress = 0.0
var is_animating
var hover_distance = 30.0
var points_drawn
var player_circles = [[], [], [], []]
var gold_tween
var label_tween
var text_color = Color.WHITE

func _ready():
	points_drawn = false
	graph_tooltip.visible = false
	stock1_value = 4
	stock1_history = [stock1_value]
	stock2_value = 4
	stock2_history = [stock2_value]
	stock3_value = 4
	stock3_history = [stock3_value]
	stock4_value = 4
	stock4_history = [stock4_value]

	line_width_value = 1
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
	$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	
	stock_value_calc()

func _process(delta):
	var temp = axis.get_children()
	if animation_progress >= 1.0:
		update_graph_tooltip()
	if not is_animating:
		return

	animation_progress = min(animation_progress + delta / draw_speed, 1.0)

	for i in range(player_lines.size()):
		var points = all_grid_points[i]
		var visible_count = int(animation_progress * points.size())
		for j in range(player_circles[i].size()):
			player_circles[i][j].visible = j < visible_count
		player_lines[i].clear_points()
		for j in range(visible_count):
			player_lines[i].add_point(points[j])

		if visible_count < points.size() and visible_count > 0:
			var next_point = points[visible_count]
			var last_point = points[visible_count - 1]
			var partial_point = last_point.lerp(next_point, (animation_progress * points.size()) - visible_count)
			player_lines[i].add_point(partial_point)

	if animation_progress >= 1.0:
		is_animating = false
	

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
				stock_evaluation(curr_fourth, -1)
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
	stock1_adj_history = grid_points(stock1_history)
	stock1_grid_points = calc_graph_points(stock1_value, stock1_adj_history, line1)
	stock2_adj_history = grid_points(stock2_history)
	stock2_grid_points = calc_graph_points(stock2_value, stock2_adj_history, line2)
	stock3_adj_history = grid_points(stock3_history)
	stock3_grid_points = calc_graph_points(stock3_value, stock3_adj_history, line3)
	stock4_adj_history = grid_points(stock4_history)
	stock4_grid_points = calc_graph_points(stock4_value, stock4_adj_history, line4)

	all_grid_points = [stock1_grid_points, stock2_grid_points, stock3_grid_points, stock4_grid_points]
	player_lines = [line1, line2, line3, line4]
	$buy_stock1/Label.text = str(Inventory.stock_finder(Inventory.id_list[0])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock1"]) + "\n Value: $" + str(stock1_value)
	$buy_stock2/Label.text = str(Inventory.stock_finder(Inventory.id_list[1])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock2"]) + "\n Value: $" + str(stock2_value)
	$buy_stock3/Label.text = str(Inventory.stock_finder(Inventory.id_list[2])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock3"]) + "\n Value: $" + str(stock3_value)
	$buy_stock4/Label.text = str(Inventory.stock_finder(Inventory.id_list[3])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock4"]) + "\n Value: $" + str(stock4_value)

	draw_hover_points()
	
	animation_progress = 0.0
	is_animating = true
	
func calc_graph_points(stock, history, stock_line):
	var graph_size = graph_area.size
	var points = stock_line.points
	
	for round in range(history.size()):
		var x = yaxis_start + (point_width * round)
		var y = xaxis_start - ((float(history[round]) / float(line_width_value)) * point_height)
		points.append(stock_line.to_local(Vector2(x,y)))
	#stock_line.points = points
	return points
	

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
	while max_stock_value > line_width_value * horiz_line_amt:
		line_width_value += 1
	
	point_height = graph_area.size.y / horiz_line_amt #min(100, graph_area.size.y / max_stock_value)
	
	var counter = 1
	while counter * point_height <= graph_area.size.y:
		var horiz_line = Line2D.new()
		var price_label = Label.new()
		horiz_line.width = 5
		horiz_line.default_color = Color.BLACK
		#horiz_line.position = Vector2(0,0)
		horiz_line.points = PackedVector2Array([Vector2(yaxis_start, xaxis_start - (counter * point_height)), Vector2(yaxis_max, xaxis_start - (counter * point_height))])
		price_label.text = str(counter * line_width_value)
		price_label.add_theme_font_size_override("font_size", 46)
		price_label.add_theme_color_override("font_color", Color.BLACK)
		price_label.position = Vector2(yaxis_start - 100, xaxis_start - (counter * point_height) - 20)
		axis.add_child(horiz_line)
		axis.add_child(price_label)
		counter += 1 

func draw_y_lines():
	if (Inventory.rounds + 1) > vert_line_amt:
		point_width = graph_area.size.x / vert_line_amt
		Inventory.stock_y_label_adj += 1
	else:
		point_width = graph_area.size.x / (Inventory.rounds + 1)
	
	var counter = 0
	var line_adjust = 0
	while counter * point_width <= graph_area.size.x:
		var vert_line = Line2D.new()
		var round_label = Label.new()
		vert_line.width = 5
		vert_line.default_color = Color.BLACK
		#vert_line.position = Vector2(0,0)
		vert_line.points = PackedVector2Array([Vector2(yaxis_start + (counter * point_width) - line_adjust, xaxis_start), Vector2(yaxis_start + (counter * point_width) - line_adjust, xaxis_max)])
		round_label.text = str(counter + Inventory.stock_y_label_adj)
		round_label.add_theme_font_size_override("font_size", 46)
		round_label.add_theme_color_override("font_color", Color.BLACK)
		round_label.position = Vector2(yaxis_start + (counter * point_width) - line_adjust - 10, 20 + xaxis_start)
		axis.add_child(vert_line)
		axis.add_child(round_label)
		counter += 1

func grid_points(history):
	var adj_history = history.duplicate()
	var sieze = history.size()
	if history.size() > vert_line_amt:
		adj_history = adj_history.slice(Inventory.stock_y_label_adj, history.size())
	else:
		adj_history = adj_history.slice(0, history.size())
	return adj_history

func draw_hover_points():
	#var all_grid_points = [stock1_grid_points, stock2_grid_points, stock3_grid_points, stock4_grid_points]
	var colors = [line1.default_color, line2.default_color, line3.default_color, line4.default_color]

	for child in axis.get_children():
		if child.is_in_group("hover_circles"):
			child.queue_free()

	for i in range(all_grid_points.size()):
		for point in all_grid_points[i]:
			var circle = Polygon2D.new()
			var circle_points = PackedVector2Array()
			for angle in range(24):
				var a = angle * TAU / 24
				circle_points.append(Vector2(cos(a), sin(a)) * 20.0)
			circle.polygon = circle_points
			circle.color = colors[i]
			circle.add_to_group("hover_circles")
			circle.z_index = 1
			circle.visible = false
			player_circles[i].append(circle)
			axis.add_child(circle)
			circle.position = line1.to_global(point)# + Vector2(0, 100)
			
	points_drawn = true

func update_graph_tooltip():
	graph_tooltip.hide()
	var mouse_pos = get_global_mouse_position()
	var histories = [stock1_adj_history, stock2_adj_history, stock3_adj_history, stock4_adj_history]
	var grid_points = [stock1_grid_points, stock2_grid_points, stock3_grid_points, stock4_grid_points]
	var stock_names = [str(Inventory.stock_finder(Inventory.stock1_turt)), str(Inventory.stock_finder(Inventory.stock2_turt)), str(Inventory.stock_finder(Inventory.stock3_turt)), str(Inventory.stock_finder(Inventory.stock4_turt))]
	var best_distance = hover_distance
	var best_player = -1
	var best_point = -1

	for i in range(player_lines.size()):
		for j in range(min(player_lines[i].points.size(), grid_points[i].size())):
			var point_pos = player_lines[i].to_global(player_lines[i].points[j])
			var distance = mouse_pos.distance_to(point_pos)
			if distance < best_distance:
				best_distance = distance
				best_player = i
				best_point = j

	if best_player == -1:
		return

	var history = histories[best_player]
	var round_number
	if int(Inventory.rounds) < vert_line_amt:
		round_number = best_point
	else:
		round_number = best_point + Inventory.stock_y_label_adj #(int(Inventory.rounds) - (Inventory.stock_y_label_adj) + 1)
	var stock_value = history[best_point] if best_point < history.size() else "?"
	graph_tooltip.text = "Stock: %s\nValue: %s\nRound: %s" % [stock_names[best_player], stock_value, round_number]
	graph_tooltip.global_position = mouse_pos + Vector2(15, 15)
	graph_tooltip.show()

func _on_shop_pressed() -> void:
	for child in axis.get_children():
		child.queue_free()
	MusicManager.play_effect("button_click")
	get_tree().change_scene_to_file("res://ScenesAndScripts/shop.tscn")

func _on_buy_stock_1_pressed() -> void:
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= stock1_value:
		MusicManager.play_effect("button_click")
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= stock1_value
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock1"] += 1
		$buy_stock1/Label.text = str(Inventory.stock_finder(Inventory.id_list[0])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock1"]) + "\n Value: $" + str(stock1_value)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	else:
		shake_gold()

func _on_sell_stock_1_pressed() -> void:
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock1"] > 0:
		MusicManager.play_effect("button_click")
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock1"] -= 1
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += stock1_value
		$buy_stock1/Label.text = str(Inventory.stock_finder(Inventory.id_list[0])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock1"]) + "\n Value: $" + str(stock1_value)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	else:
		shake_stock($buy_stock1/Label)

func _on_buy_stock_2_pressed() -> void:
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= stock2_value:
		MusicManager.play_effect("button_click")
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= stock2_value
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock2"] += 1
		$buy_stock2/Label.text = str(Inventory.stock_finder(Inventory.id_list[1])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock2"]) + "\n Value: $" + str(stock2_value)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	else:
		shake_gold()

func _on_sell_stock_2_pressed() -> void:
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock2"] > 0:
		MusicManager.play_effect("button_click")
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock2"] -= 1
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += stock2_value
		$buy_stock2/Label.text = str(Inventory.stock_finder(Inventory.id_list[1])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock2"]) + "\n Value: $" + str(stock2_value)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	else:
		shake_stock($buy_stock2/Label)

func _on_buy_stock_3_pressed() -> void:
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= stock3_value:
		MusicManager.play_effect("button_click")
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= stock3_value
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock3"] += 1
		$buy_stock3/Label.text = str(Inventory.stock_finder(Inventory.id_list[2])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock3"]) + "\n Value: $" + str(stock3_value)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	else:
		shake_gold()

func _on_sell_stock_3_pressed() -> void:
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock3"] > 0:
		MusicManager.play_effect("button_click")
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock3"] -= 1
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += stock3_value
		$buy_stock3/Label.text = str(Inventory.stock_finder(Inventory.id_list[2])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock3"]) + "\n Value: $" + str(stock3_value)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	else:
		shake_stock($buy_stock3/Label)

func _on_buy_stock_4_pressed() -> void:
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= stock4_value:
		MusicManager.play_effect("button_click")
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= stock4_value
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock4"] += 1
		$buy_stock4/Label.text = str(Inventory.stock_finder(Inventory.id_list[3])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock4"]) + "\n Value: $" + str(stock4_value)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	else:
		shake_gold()

func _on_sell_stock_4_pressed() -> void:
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock4"] > 0:
		MusicManager.play_effect("button_click")
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock4"] -= 1
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += stock4_value
		$buy_stock4/Label.text = str(Inventory.stock_finder(Inventory.id_list[3])) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock4"]) + "\n Value: $" + str(stock4_value)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	else:
		shake_stock($buy_stock4/Label)

func shake_gold():
	if gold_tween and gold_tween.is_running():
		gold_tween.kill()

	var original_position = $Gold.position
	var original_color = text_color
	MusicManager.play_effect("button_error")
	
	gold_tween = create_tween()
	gold_tween.set_parallel()
	gold_tween.tween_property($Gold, "modulate", Color.RED, 0.1).set_trans(Tween.TRANS_QUAD)
	gold_tween.tween_property($Gold, "position:x", original_position.x + 10, 0.04).set_delay(0.0)
	gold_tween.chain().tween_property($Gold, "position:x", original_position.x - 6, 0.04)
	gold_tween.chain().tween_property($Gold, "position:x", original_position.x + 4, 0.04)
	gold_tween.chain().tween_property($Gold, "position:x", original_position.x, 0.04)
	gold_tween.tween_property($Gold, "modulate", original_color, 0.2).set_delay(0.15)

func shake_stock(label):
	if label_tween and label_tween.is_running():
		label_tween.kill()
	
	var original_position = label.position
	var original_color = text_color
	MusicManager.play_effect("button_error")
	
	gold_tween = create_tween()
	gold_tween.set_parallel()
	gold_tween.tween_property(label, "modulate", Color.RED, 0.1).set_trans(Tween.TRANS_QUAD)
	gold_tween.tween_property(label, "position:x", original_position.x + 10, 0.04).set_delay(0.0)
	gold_tween.chain().tween_property(label, "position:x", original_position.x - 6, 0.04)
	gold_tween.chain().tween_property(label, "position:x", original_position.x + 4, 0.04)
	gold_tween.chain().tween_property(label, "position:x", original_position.x, 0.04)
	gold_tween.tween_property(label, "modulate", original_color, 0.2).set_delay(0.15)
