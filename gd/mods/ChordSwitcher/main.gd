class_name ChordSwitcher
extends Node

var file_path = "user://custom_chords.json"
var saved = []
var selected_index = 0

func l(message: String):
	print("ChordSwitcher: " + message)

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
		
	load_chords_from_file()
	l("Ready!")

func findGuitarNode() -> Node:
	return find_node_with_script(get_tree().root, "res://Scenes/Minigames/Guitar/guitar_minigame.gd")
	
func find_node_with_script(root: Node, script_path: String) -> Node:
	if root.get_script() and root.get_script().resource_path == script_path:
		return root
	
	for child in root.get_children():
		var found = find_node_with_script(child, script_path)
		if found:
			return found
	
	return null

func notify(message: String, code: int = 0) -> void:
	l(message)
	PlayerData._send_notification(message, code)

func refresh_guitar(guitar: Node):
	if guitar != null:
		guitar._select_shape(guitar.selected_shape)

func ld(index: int) -> void:
	var guitar = findGuitarNode()
	
	if guitar == null:
		notify("Failed to find guitar", 1)
		return

	selected_index = index
	guitar.saved_shapes = saved[index]
	refresh_guitar(guitar)
	
	notify("Loading from " + str(index + 1))

func sv(index: int) -> void:
	var guitar = findGuitarNode()
	
	if guitar == null:
		notify("Failed to find guitar!", 1)
		return
	
	saved[index] = guitar.saved_shapes
	
	notify("Saving in " + str(index + 1))

func save_chords_to_file() -> void:
	var file = File.new()
	if file.open(file_path, File.WRITE) == OK:
		var json = to_json(saved)
		file.store_string(json)
		file.close()
		notify("Saved chords to file!")
	else:
		notify("Failed to save chords", 1)
		
func load_chords_from_file() -> void:
	var file = File.new()
	if file.open(file_path, File.READ) == OK:
		var json = file.get_as_text()
		saved = parse_json(json) 
		file.close()
		notify("Loaded chords from file!")
		
		var guitar = findGuitarNode()
		if guitar != null:
			guitar.saved_shapes = saved[selected_index]
			refresh_guitar(guitar)
	else:
		notify("Failed to load chords", 1)

func _input(event):
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
