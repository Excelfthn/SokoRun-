extends Node2D

var game_end = false

func _process(_delta):
	if game_end == false:
		var boxGoals = $BoxGoals.get_child_count()
		for i in $BoxGoals.get_children():
			if i.occupied:
				boxGoals -= 1
		
		if boxGoals == 0:
			$AcceptDialog.popup()
			game_end = true

func _on_accept_dialog_confirmed():
	get_tree().reload_current_scene()
