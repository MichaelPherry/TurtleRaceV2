extends Node

func arm(item):
	match item:
		"fissile":
			return load("res://Items/fissile.tres")
		"eel_spit":
			return load("res://Items/eel_spit.tres")
		"mystery_item":
			return load("res://Items/mystery_item.tres")
		"bear_trap":
			return load("res://Items/bear_trap.tres")

func head(item):
	match head:
		"propreller":
			return load("res://Passives/propreller.tres")
