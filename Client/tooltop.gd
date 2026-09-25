extends Panel

@onready var nameLabel = $VBoxContainer/Name
@onready var descriptionLabel = $VBoxContainer/Description

func show_item(item):
	self.visible = true
	nameLabel.text = item.name
	descriptionLabel.text = item.description
	
func hide_tooltip():
	self.visible = false
