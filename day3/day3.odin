package day3

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Num :: struct {
    line_no:   int,
    start_idx: int,
    value:     string,
}

Symbol :: struct {
    line_no: int,
    idx:     int,
    value:   rune,
}

find_nums_and_gears :: proc(file: ^string) -> ([dynamic]Symbol, [dynamic]Num) {
    out_sym := make([dynamic]Symbol)
    out_num := make([dynamic]Num)

    current_num: Num = {0, 0, ""}
    finding_num := false
    str_builder := strings.builder_make()
    defer strings.builder_destroy(&str_builder)

    line_no: int = 0
    for line in strings.split_lines_iterator(file) {
        for rn, i in line {
            switch rn {
            case '0' ..= '9':
                if finding_num {
                    strings.write_rune(&str_builder, rn)
                } else {
                    finding_num = true
                    strings.builder_reset(&str_builder)
                    strings.write_rune(&str_builder, rn)
                    current_num = {line_no, i, ""}
                }
                continue
            }
            if finding_num {
                current_num.value = strings.clone(strings.to_string(str_builder))
                append(&out_num, current_num)
                finding_num = false
            }
            if rn != '.' {
                append(&out_sym, Symbol{line_no, i, rn})
            }
        }
        if finding_num {
            current_num.value = strings.clone(strings.to_string(str_builder))
            append(&out_num, current_num)
            finding_num = false
        }
        line_no += 1
    }

    return out_sym, out_num
}

is_num_adj_to_symbol :: proc(num: Num, symbol: Symbol) -> bool {
    i := num.line_no == 0 ? 0 : num.line_no - 1
    for ; i <= num.line_no + 1; i += 1 {
        j := num.start_idx == 0 ? 0 : num.start_idx - 1
        for ; j <= num.start_idx + len(num.value); j += 1 {
            if symbol.line_no == i && symbol.idx == j {
                return true
            }
        }
    }
    return false
}

solution1 :: proc(file: ^string) -> int {
    symbols, nums := find_nums_and_gears(file)
    defer {
        delete(symbols)
        delete(nums)
    }

    sum := 0
    for n in nums {
        adjs := 0
        for s in symbols {
            adjs += is_num_adj_to_symbol(n, s) ? 1 : 0
        }
        v, ok := strconv.parse_int(n.value)
        if ok {
            sum += v * adjs
        }
    }
    return sum
}

solution2 :: proc(file: ^string) -> int {
    symbols, nums := find_nums_and_gears(file)
    defer {
        delete(symbols)
        delete(nums)
    }

    sum := 0
    for s in symbols {
        adjs := 0
        product := 1
        for n in nums {
            if s.value == '*' && is_num_adj_to_symbol(n, s) {
                adjs += 1
                v, ok := strconv.parse_int(n.value)
                if ok {
                    product *= v
                }
            }
        }
        if adjs == 2 {
            sum += product
        }
    }
    return sum
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
