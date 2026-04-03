extends Control

@onready var story_text: RichTextLabel = $StoryPanel/MarginContainer/ScrollContainer/StoryText
@onready var choices_panel: VBoxContainer = $ChoicesPanel

func display_section(section: BookSection) -> void:
	story_text.text = section.text
	
	for child in choices_panel.get_children():
		child.queue_free()
	
	if section.event != "":
		BookManager.trigger_event(section)
		return
	
	for choice in section.choices:
		var btn := Button.new()
		btn.text = choice.label
		btn.pressed.connect(func(): BookManager.go_to_section(choice.goto_section))
		choices_panel.add_child(btn)
