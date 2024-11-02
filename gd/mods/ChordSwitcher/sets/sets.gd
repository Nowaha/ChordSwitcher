extends Panel

onready var mod: Node = get_node("/root/ChordSwitcher")

onready var sets_container: GridContainer = $VBoxContainer/setscontainer

func _ready():
	mod.connect("_switched_set", self, "_on_switched_set")
	
	var i = 0
	for child in sets_container.get_children():
		child.text = str(i + 1)
		child.connect("pressed", self, "_on_button_click", [i])
		i += 1
		
	_refresh()

func _on_switched_set(index: int) -> void:
	_refresh()
	
func _on_button_click(index: int) -> void:
	mod.ld(index)

func _refresh() -> void:
	var selected = mod.selected_index

	var i = 0
	for child in sets_container.get_children():
		child.disabled = selected == i
		i += 1

func _on_Save_pressed():
	mod.save_chords_to_file()

func _on_Reload_pressed():
	mod.load_chords_from_file()
