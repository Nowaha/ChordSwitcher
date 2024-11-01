class_name ChordSwitcher
extends Node

var file_path: String = "user://custom_chords.json"
var ever_saved: bool = false
var saved: Array = []
var selected_index: int = 0
var guitar: Node = null

func _ready():
	var i = 0
	while i < 9:
		saved.append([
			[0, 0, 0, 0, 0, 0], 
			[0, 0, 0, 0, 0, 0], 
			[0, 0, 0, 0, 0, 0], 
			[0, 0, 0, 0, 0, 0], 
			[0, 0, 0, 0, 0, 0], 
			[0, 0, 0, 0, 0, 0], 
			[0, 0, 0, 0, 0, 0], 
			[0, 0, 0, 0, 0, 0], 
			[0, 0, 0, 0, 0, 0], 
		])
		i += 1
		
	ever_saved = load_chords_from_file()

	l("Ready!")
	
func _inject(guitar_node: Node) -> void:
	l("Injecting guitar")
	guitar = guitar_node
	
	if ever_saved:
		guitar.saved_shapes = saved[selected_index].duplicate()
		refresh_guitar(guitar)
	else:
		saved[0] = guitar.saved_shapes.duplicate()
		ever_saved = save_chords_to_file()
	
	guitar.connect("tree_exiting", self, "_guitar_closed")

func _guitar_closed():
	l("Disconnecting from guitar")
	guitar = null

func refresh_guitar(guitar: Node):
	guitar._select_shape(guitar.selected_shape)

func ld(index: int) -> void:
	if guitar == null:
		notify("Failed to find guitar", 1)
		return

	selected_index = index
	guitar.saved_shapes = saved[index].duplicate()
	refresh_guitar(guitar)
	
	notify("Loading from " + str(index + 1))

func sv(index: int) -> void:
	if guitar == null:
		notify("Failed to find guitar!", 1)
		return
	
	saved[index] = guitar.saved_shapes.duplicate()
	
	notify("Saving in " + str(index + 1))

func save_chords_to_file() -> bool:
	var file = File.new()
	if file.open(file_path, File.WRITE) == OK:
		var json = to_json(saved)
		file.store_string(json)
		file.close()
		notify("Saved chords to file!")
		return true
	else:
		notify("Failed to save chords", 1)
		return false
		
func load_chords_from_file() -> bool:
	var file = File.new()
	if file.open(file_path, File.READ) == OK:
		var json = file.get_as_text()
		saved = parse_json(json) 
		file.close()
		notify("Loaded chords from file!")
		
		if guitar != null:
			guitar.saved_shapes = saved[selected_index].duplicate()
			refresh_guitar(guitar)
		
		return true
	else:
		notify("Failed to load chords", 1)
		return false

func _input(event):
	if guitar == null: return
	
	if event is InputEventKey and event.pressed:
		if event.scancode >= KEY_F1 and event.scancode <= KEY_F9:
			var i = event.scancode - KEY_F1
			if event.control:
				sv(i)
			elif !event.shift:
				ld(i)
		elif event.scancode == KEY_F10 and event.shift:
			load_chords_from_file()
		elif event.scancode == KEY_F11 and event.shift:
			save_chords_to_file()


# Utils
func l(message: String):
	print("ChordSwitcher: " + message)

func findGuitarNode() -> Node:
	return get_node("/root/playerhud/guitar")

func notify(message: String, code: int = 0) -> void:
	l(message)
	PlayerData._send_notification(message, code)
