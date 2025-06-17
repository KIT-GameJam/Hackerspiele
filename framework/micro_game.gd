class_name MicroGame
extends Node

signal win
signal loss

## This function is called, when the timer expires.
## It should emit win or loss.
func on_timeout() -> void:
	loss.emit()
