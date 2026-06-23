package arfont

import "core:encoding/json"
import "core:os"

parse_json_file :: proc(file: ^os.File) -> (font: Font) {
	data, _ := os.read_entire_file(file, context.temp_allocator)
	json.unmarshal(data, &font)
	free_all(context.temp_allocator)
	return
}

// TODO: implement this
parse_arfont_file :: proc(file: ^os.File) -> (font: Font, atlasImage: []byte) {
	return
}

