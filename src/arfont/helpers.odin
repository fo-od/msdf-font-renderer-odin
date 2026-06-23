package arfont

import "core:fmt"

getGlyph :: proc(font: Font, char: i32) -> Glyph {
	for g in font.glyphs {
		if g.unicode == char do return g
	}
	fmt.eprintfln("Can't find glyph for unicode '%v'", char)
	return {unicode = -1}
}

measure_text :: proc(font: Font, text: string, scale: f32 = 1.0) -> (width, height: f32) {
	bottom, top: f32
	for c in text {
		char := transmute(i32)c
		glyph := getGlyph(font, char)

		b := glyph.planeBounds.bottom * font.atlas.size * scale
		t := glyph.planeBounds.top * font.atlas.size * scale
		if b < bottom do bottom = b
		if t > top do top = t

		width += glyph.advance * font.atlas.size * scale
	}

	height = top - bottom
	return
}

