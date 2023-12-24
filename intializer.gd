extends Node
## The Initializer is simply a autoload script, accessed with _INIT, that has a dictionary,
## _INIT.data, which carries initialization data. It loads this data at the start of the
## program and saves it when the program quits, to an easily readible txt file for the
## gamer to modify at will. It should be used to save user options like keyboard layouts
## or volume settings. It should NOT be used for things like save games, or anything that
## ought to be resistant to hacking.
 
## The dictionary that gets converted to and from a text file on game start.
var data = {}
var _NAME = ProjectSettings["application/config/name"]
var _FILE = "user://%s init.txt" % _NAME

const POSITION = "window position"
const SIZE = "window size"
const MODE = "window mode"

func Save():
	data[MODE] = DisplayServer.window_get_mode()
	if data[MODE] == DisplayServer.WINDOW_MODE_WINDOWED:
		data[SIZE] = DisplayServer.window_get_size()
		data[POSITION] = DisplayServer.window_get_position()
	
	var file = FileAccess.open(_FILE,FileAccess.WRITE)
	file.store_string(var_to_str(data))
	

signal loaded
var is_loaded := false

func Load():
	is_loaded = false
	if not FileAccess.file_exists(_FILE): 
		Save()
		is_loaded = true
		emit_signal("loaded")
		return
	var sample_data = str_to_var(FileAccess.get_file_as_string(_FILE))
	if sample_data is Dictionary: data = sample_data
	else : 
		is_loaded = true
		emit_signal("loaded")
		return
	
	if data.has(POSITION): DisplayServer.window_set_position(data[POSITION])
	if data.has(SIZE): DisplayServer.window_set_size(data[SIZE])
	if data.has(MODE): 
		await get_tree().process_frame
		DisplayServer.window_set_mode(data[MODE])

	is_loaded = true
	emit_signal("loaded")


func _ready():
	await get_tree().process_frame
	Load()
	if not is_loaded: await loaded
	Save()

func _process(delta):
	pass

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or \
	what == NOTIFICATION_WM_SIZE_CHANGED:
		if not is_loaded: await loaded
		Save()
