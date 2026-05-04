class_name ScoreCalculator
extends RefCounted


static func calculate(pairs_matched: int, guesses: int) -> int:
	var safe_guesses: int = maxi(1, guesses)
	var ratio: float = float(pairs_matched) / float(safe_guesses)
	return floori(ratio * 1000.0)
