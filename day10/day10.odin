package Day10

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode"

Coord :: [2]int

Bounds :: struct {
	min_x: int,
	max_x: int,
	min_y: int,
	max_y: int,
}

find_loop_start :: proc(input: ^string) -> Coord {
	start_coord := Coord{0, 0}
	for char in input^ {
		if char == 'S' {
			break
		}
		if char == '\n' {
			start_coord = {0, start_coord.y + 1}
		} else {
			start_coord.x += 1
		}
	}
	return start_coord
}

find_loop :: proc(input: ^string) -> [dynamic]Coord {
	coord := find_loop_start(input)
	out := make([dynamic]Coord)

	lines := strings.split_lines(input^)
	defer delete(lines)

	for {
		char := rune(lines[coord.y][coord.x])
		append(&out, coord)

		switch char {
		case 'S':
			if strings.contains_rune("-LF", rune(lines[coord.y][coord.x - 1])) {
				coord.x -= 1
			} else if strings.contains_rune("-J7", rune(lines[coord.y][coord.x + 1])) {
				coord.x += 1
			} else if strings.contains_rune("|JF", rune(lines[coord.y - 1][coord.x])) {
				coord.y -= 1
			} else {
				coord.y += 1
			}
		case '|':
			prev := out[len(out) - 2]
			if prev.y < coord.y {
				coord.y += 1
			} else {
				coord.y -= 1
			}
		case '-':
			prev := out[len(out) - 2]
			if prev.x < coord.x {
				coord.x += 1
			} else {
				coord.x -= 1
			}
		case 'L':
			prev := out[len(out) - 2]
			if prev.y < coord.y {
				coord.x += 1
			} else {
				coord.y -= 1
			}
		case 'J':
			prev := out[len(out) - 2]
			if prev.x < coord.x {
				coord.y -= 1
			} else {
				coord.x -= 1
			}
		case '7':
			prev := out[len(out) - 2]
			if prev.x < coord.x {
				coord.y += 1
			} else {
				coord.x -= 1
			}
		case 'F':
			prev := out[len(out) - 2]
			if prev.x > coord.x {
				coord.y += 1
			} else {
				coord.x += 1
			}
		}

		if coord == out[0] {
			break
		}
	}

	return out
}

TileState :: enum {
	Inside,
	Pipe,
	Outside,
}

mark_outside :: proc(coord: Coord, states: ^[dynamic][dynamic]TileState) {
	if next := states^[coord.y][coord.x - 1]; coord.x != 0 && next != .Outside && next != .Pipe {
		states^[coord.y][coord.x - 1] = .Outside
		mark_outside({coord.x - 1, coord.y}, states)
	}
	if next := states^[coord.y - 1][coord.x]; coord.y != 0 && next != .Outside && next != .Pipe {
		states^[coord.y - 1][coord.x] = .Outside
		mark_outside({coord.x, coord.y - 1}, states)
	}

	if next := states^[coord.y][coord.x + 1];
	   coord.x + 1 < len(states[0]) && next != .Outside && next != .Pipe {
		states^[coord.y][coord.x + 1] = .Outside
		mark_outside({coord.x + 1, coord.y}, states)
	}
	if next := states^[coord.y + 1][coord.x];
	   coord.y + 1 < len(states) && next != .Outside && next != .Pipe {
		states^[coord.y + 1][coord.x] = .Outside
		mark_outside({coord.x, coord.y + 1}, states)
	}
}

// this almost works - it cannot "squeeze between" pipes, like in the puzzle
find_enclosed_tiles :: proc(loop: [dynamic]Coord, bounds: Bounds) -> [dynamic]Coord {
	states := make([dynamic][dynamic]TileState)
	defer {
		for ts in states {
			delete(ts)
		}
		delete(states)
	}
	out := make([dynamic]Coord)

	for i in 0 ..= (bounds.max_y - bounds.min_y) {
		append(&states, make([dynamic]TileState))
		for j in 0 ..= (bounds.max_x - bounds.min_x) {
			append(&states[i], TileState.Inside)
		}
	}
	max_y := len(states)
	max_x := len(states[0])

	for pipe in loop {
		states[pipe.y - bounds.min_y][pipe.x - bounds.min_x] = .Pipe
	}
	for i in 0 ..< max_y {
		if states[i][0] != .Pipe {
			states[i][0] = .Outside
		}
		if states[i][max_x - 1] != .Pipe {
			states[i][max_x - 1] = .Outside
		}
	}
	for i in 0 ..< max_x {
		if states[0][i] != .Pipe {
			states[0][i] = .Outside
		}
		if states[max_y - 1][i] != .Pipe {
			states[max_y - 1][i] = .Outside
		}
	}

	for i in 0 ..< max_y {
		if states[i][0] == .Outside {
			mark_outside({0, i}, &states)
		}
		if states[i][max_x - 1] == .Outside {
			mark_outside({max_x - 1, i}, &states)
		}
	}
	for i in 0 ..< max_x {
		if states[0][i] == .Outside {
			mark_outside({i, 0}, &states)
		}
		if states[max_y - 1][i] == .Outside {
			mark_outside({i, max_y - 1}, &states)
		}
	}

	for line, y in states {
		for state, x in line {
			if state == .Inside {
				append(&out, Coord{bounds.min_x + x, bounds.min_y + y})
			}
		}
	}

	return out
}

solution1 :: proc(file: ^string) -> int {
	loop := find_loop(file)
	defer delete(loop)
	return len(loop) / 2
}

solution2 :: proc(file: ^string) -> int {
	loop := find_loop(file)
	defer delete(loop)
	bounds := Bounds{loop[0].x, loop[0].x, loop[0].y, loop[0].y}
	for coord in loop {
		bounds.max_x = max(bounds.max_x, coord.x)
		bounds.min_x = min(bounds.min_x, coord.x)
		bounds.max_y = max(bounds.max_y, coord.y)
		bounds.min_y = min(bounds.min_y, coord.y)
	}
	enclosed := find_enclosed_tiles(loop, bounds)
	defer delete(enclosed)
	return len(enclosed)
}

main :: proc() {
	data, ok := os.read_entire_file(os.args[1])
	defer delete(data)
	if !ok {
		fmt.println("No file?")
		return
	}

	it := string(data)
	fmt.println(solution2(&it))
}
