extends Node2D

var is_breaking := false

func break_block():
	if is_breaking:
		return
	
	is_breaking = true
	queue_free()  
