package arfont

import "core:encoding/json"
import "core:fmt"
import "core:os"

parse_json_file :: proc(file: ^os.File) -> (font: Font) {
	data, _ := os.read_entire_file(file, context.temp_allocator)
	err := json.unmarshal(data, &font)
	if err != nil do fmt.printfln("JSON error: %v", err)
	free_all(context.temp_allocator)
	return
}

// TODO: implement this
parse_arfont_file :: proc(file: ^os.File) -> (font: Font, atlasImage: []byte) {
	return
}

