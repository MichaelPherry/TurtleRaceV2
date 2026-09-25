extends Node2D

var buff_amount = 10.0
func apply():
	Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["resilience"] += buff_amount
