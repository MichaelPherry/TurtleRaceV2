extends Node

var turt_score = {
	"1" : 0,
	"2" : 0,
	"3" : 0,
	"4" : 0
}

func arm(item):
	match item.name:
		"fissile":
			return load("res://Items/fissile.tres")
		"eel_spit":
			return load("res://Items/eel_spit.tres")
		"mystery_item":
			return load("res://Items/mystery_item.tres")
