class_name ChordSwitcher
extends Node

signal _switched_set(index)

var selected_index: int = 0

var file_path: String = "user://custom_chords.json"
var ever_saved: bool = false
var saved: Array = []
var guitar: Node = null

func _ready():
	var i = 0
	while i < 9:
		saved.append(PlayerData.DEFAULT_GUITAR_SHAPES.duplicate())
		i += 1

	ever_saved = load_chords_from_file()

	l("Ready!")
	
func _inject(guitar_node: Node) -> void:
	l("Injecting guitar")
	guitar = guitar_node
	guitar.connect("tree_exiting", self, "_guitar_closed")
	guitar.connect("_fret_update", self, "_on_fret_update")
	
	if ever_saved:
		guitar.saved_shapes = saved[selected_index].duplicate(true)
		refresh_guitar(guitar)
	else:
		saved[0] = guitar.saved_shapes.duplicate(true)
		ever_saved = save_chords_to_file()
	
	var fret_main = guitar.get_child(1)
	var sets: Panel = load("res://mods/ChordSwitcher/sets/sets.tscn").instance()
	fret_main.add_child(sets)

func _guitar_closed() -> void:
	l("Disconnecting from guitar")
	guitar = null

func refresh_guitar(guitar: Node) -> void:
	guitar._select_shape(guitar.selected_shape)

func ld(index: int) -> void:
	if guitar == null:
		notify("Failed to find guitar", 1)
		return

	selected_index = index
	guitar.saved_shapes = saved[index].duplicate(true)
	refresh_guitar(guitar)
	
	l("Loading from " + str(index + 1))
	emit_signal("_switched_set", index)

func _on_fret_update(string, fret, is_chord) -> void:
	if is_chord: return
	sv(selected_index)

func sv(index: int) -> void:
	if guitar == null:
		notify("Failed to find guitar!", 1)
		return
	
	saved[index] = guitar.saved_shapes.duplicate(true)
	
	l("Saving in " + str(index + 1))

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
			guitar.saved_shapes = saved[selected_index].duplicate(true)
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


# Utils
func l(message: String) -> void:
	print("ChordSwitcher: " + message)

func findGuitarNode() -> Node:
	return get_node("/root/playerhud/guitar")

func notify(message: String, code: int = 0) -> void:
	l(message)
	PlayerData._send_notification(message, code)
