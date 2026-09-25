extends Node2D

var buff_amount = 50.0
func apply():
	Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["max_speed"] += buff_amount
