extends Node

#enum PLAYERSTATE {IDLE, MOVE, JUMP, FALL, GDASH, ADASH, STOMP, HURT, SHOOT}

enum PLAYERSTATE {IDLE=3, MOVE=6, JUMP=1, FALL=4, GDASH=9, ADASH=12, STOMP=7, HURT=10, SHOOT=2}

func is_aerial_state(state:PLAYERSTATE) -> bool:
	if state%3 == 1:
		return true
	return false
