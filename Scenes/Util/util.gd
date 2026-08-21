class_name Util

enum Direction {NORTH, EAST, SOUTH, WEST}

const direchtion_dict = {
	Direction.NORTH: "n",
	Direction.EAST: "e",
	Direction.SOUTH: "s",
	Direction.WEST: "w"
}

static func translate_direction_to_char(direction:Direction) -> String:
	return direchtion_dict[direction]
