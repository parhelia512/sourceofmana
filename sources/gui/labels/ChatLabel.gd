extends RichTextLabel
class_name ChatLabel

@onready var contextMenu : PopupMenu		= $ContextMenu

#
func _ready():
	contextMenu.id_pressed.connect(OnContextMenuPressed)

func _gui_input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		contextMenu.position = Vector2i(get_screen_position() + event.position)
		contextMenu.popup()

func OnContextMenuPressed(id : int):
	match id:
		0: # Clear
			text = ""
