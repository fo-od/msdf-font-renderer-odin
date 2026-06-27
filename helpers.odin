package msdf_font_renderer

import "core:fmt"

getGlyph :: proc(font: Font, char: i32) -> Glyph {
	for g in font.glyphs {
		if g.unicode == char do return g
	}
	fmt.eprintfln("Can't find glyph for unicode '%v'", char)
	return {unicode = -1}
}

get_text_bounds :: proc(
	font: Font,
	text: string,
	scale: f32 = 1.0,
) -> (
	min_x, max_x, min_y, max_y: f32,
) {
	if len(text) == 0 do return

	current_x: f32 = 0
	adv: f32 = 0
	first := true

	for c in text {
		current_x += adv
		char := transmute(i32)c
		glyph := getGlyph(font, char)
		adv = glyph.advance * font.atlas.size * scale

		if glyph.unicode == -1 do continue

		glyph_left := current_x + (glyph.planeBounds.left * font.atlas.size * scale)
		glyph_right := current_x + (glyph.planeBounds.right * font.atlas.size * scale)
		glyph_bottom := glyph.planeBounds.bottom * font.atlas.size * scale
		glyph_top := glyph.planeBounds.top * font.atlas.size * scale

		if first {
			min_x = glyph_left
			max_x = glyph_right
			min_y = glyph_bottom
			max_y = glyph_top
			first = false
		} else {
			if glyph_left < min_x do min_x = glyph_left
			if glyph_right > max_x do max_x = glyph_right
			if glyph_bottom < min_y do min_y = glyph_bottom
			if glyph_top > max_y do max_y = glyph_top
		}
		max_x = current_x + adv
	}
	return
}

measure_text :: proc(font: Font, text: string, scale: f32 = 1.0) -> (width, height: f32) {
	min_x, max_x, min_y, max_y := get_text_bounds(font, text, scale)
	width = max_x - min_x
	height = max_y - min_y
	return
}

