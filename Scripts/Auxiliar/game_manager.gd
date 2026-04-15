extends Node
## Global game state — registered as an Autoload named "GameManager".

signal score_changed(player_index: int, new_score: int)
signal game_over(winner_index: int)

## Number of round wins required to win the match.
var max_score: int = 3

var _scores: Dictionary = {1: 0, 2: 0}


func add_score(player_index: int) -> void:
	_scores[player_index] += 1
	score_changed.emit(player_index, _scores[player_index])
	if _scores[player_index] >= max_score:
		game_over.emit(player_index)


func get_score(player_index: int) -> int:
	return _scores.get(player_index, 0)


func reset_scores() -> void:
	_scores = {1: 0, 2: 0}
