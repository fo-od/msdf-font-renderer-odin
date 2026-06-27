package msdf_font_renderer

import arfont_decoder "arfont-decoder"
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

// only supports 1 MSDF image
parse_arfont :: proc(file: ^os.File) -> (font: Font, texture: []byte) {
	arf: arfont_decoder.ArteryFont
	arfont_decoder.decode(&arf, file)

	tex := arf.images[0]
	texture = tex.data

	font.atlas.distanceRange = arf.variants[0].metrics.distanceRange
	font.atlas.distanceRangeMiddle = arf.variants[0].metrics.distanceRangeMiddle
	font.atlas.size = arf.variants[0].metrics.fontSize
	font.atlas.type = "msdf"
	font.atlas.height = tex.height
	font.atlas.width = tex.width
	font.atlas.yOrigin = "top" if tex.rawBinaryFormat.orientation == .TopDown else "bottom"

	newGlyphs, _ := make([dynamic]Glyph, len(arf.variants[0].glyphs))
	for glyph, i in arf.variants[0].glyphs {
		newGlyph: Glyph = {
			unicode     = cast(i32)glyph.codepoint,
			advance     = glyph.advance.h,
			planeBounds = transmute(Bounds)glyph.planeBounds,
			atlasBounds = transmute(Bounds)glyph.imageBounds,
		}

		assign_at(&newGlyphs, i, newGlyph)
	}

	font.glyphs = newGlyphs[:]

	font.kerning = transmute([]KernPair)arf.variants[0].kernPairs

	font.name = arf.variants[0].name

	font.metrics.ascender = arf.variants[0].metrics.ascender
	font.metrics.descender = arf.variants[0].metrics.descender
	font.metrics.emSize = arf.variants[0].metrics.emSize
	font.metrics.lineHeight = arf.variants[0].metrics.emSize
	font.metrics.underlineThickness = arf.variants[0].metrics.underlineThickness
	font.metrics.underlineY = arf.variants[0].metrics.underlineY
	return
}

