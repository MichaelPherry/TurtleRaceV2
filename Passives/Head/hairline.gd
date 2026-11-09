extends Node2D

var user
var effect = false
var stocks_owned = 0
var stocks = ["stock1", "stock2", "stock3", "stock4"]

func _ready():
	for stock in stocks:
		stocks_owned += Inventory.server_turtles[user.id]["econ"][stock]
	
	user.max_speed += (stocks_owned * 2)
