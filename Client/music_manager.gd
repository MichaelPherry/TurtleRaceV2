extends Node2D

var current_lead
var duration = 2.0
var background_vol = 0
var lead_vol = 0

@onready var mainmenu = $Mainmenu
@onready var bass = $Bass
@onready var organ = $Organ
@onready var piano = $Piano
@onready var trumpet = $Trumpet
@onready var whistle = $Whistle
var instruments = [organ, piano, trumpet, whistle]

func _ready():
	current_lead = null
	mainmenu.play()
	mainmenu.volume_db = 0
	bass.play()
	organ.play()
	piano.play()
	trumpet.play()
	whistle.play()
	
func switch(switch_lead):
	organ.volume_db = -80.0
	piano.volume_db = -80.0
	trumpet.volume_db = -80.0
	whistle.volume_db = -80.0
	switch_lead.volume_db = lead_vol

func fade_in():
	if bass.volume_db < lead_vol:
		var tween = create_tween()
		tween.tween_property(bass, "volume_db", lead_vol, duration)
		current_lead = fade_in
