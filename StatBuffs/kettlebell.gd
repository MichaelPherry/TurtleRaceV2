extends Node2D

var buff_amount = 0.1
func apply():
	Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["luck"] += buff_amount
