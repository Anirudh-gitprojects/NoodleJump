extends Node

@onready var game=$Game
@onready var screens=$Screens
var game_in_progress=false
# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_window_event_callback(_on_window_event)
	screens.start_game.connect(_on_screens_start_game)
	screens.delete_level.connect(_on_screen_delete_level)
	# Replace with function body.
	game.player_died.connect(_on_game_player_died)
	game.pause_game.connect(_on_game_pause_game)
func _on_screens_start_game():
	game_in_progress=true
	game.new_game()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(game_in_progress)

func _on_window_event(event):
	match event:
		DisplayServer.WINDOW_EVENT_FOCUS_IN:
			print("Focus In")
			MyUtility.add_log_msg("Focus In")
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			print("Focus Out")
			MyUtility.add_log_msg("Focus out")
			if game_in_progress==true && !get_tree().paused:
				_on_game_pause_game()
				print("Window minimzed,pausing the game!")
				MyUtility.add_log_msg("Window minimized, pausing the game!")
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			get_tree().quit()
			

func _on_game_player_died(score,highscore):
	game_in_progress=false
	await(get_tree().create_timer(0.75).timeout)
	screens.game_over(score,highscore)
	
func _on_screen_delete_level():
	game_in_progress=false
	game.reset_game()

func _on_game_pause_game():
	get_tree().paused=true
	screens.pause_game()
