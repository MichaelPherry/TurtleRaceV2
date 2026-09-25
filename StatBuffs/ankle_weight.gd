extends Node2D

var buff_amount = 5.0
func apply():
	Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["acceleration"] += buff_amount
