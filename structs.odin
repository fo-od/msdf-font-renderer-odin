package msdf_font_renderer

Font :: struct {
	atlas:   Atlas `json:"atlas"`,
	name:    string `json:"name"`,
	metrics: Metrics `json:"metrics"`,
	glyphs:  []Glyph `json:"glyphs"`,
	kerning: []KernPair `json:"kerning"`,
}

Atlas :: struct {
	// only MSDF is supported.
	type:                string `json:"type"`,
	distanceRange:       f32 `json:"distanceRange"`,
	distanceRangeMiddle: f32 `json:"distanceRangeMiddle"`,
	size:                f32 `json:"size"`,
	width:               int `json:"width"`,
	height:              int `json:"height"`,
	// either bottom or top
	yOrigin:             string `json:"yOrigin"`,
}

Metrics :: struct {
	emSize:             f32 `json:"emSize"`,
	lineHeight:         f32 `json:"lineHeight"`,
	ascender:           f32 `json:"ascender"`,
	descender:          f32 `json:"descender"`,
	underlineY:         f32 `json:"underlineY"`,
	underlineThickness: f32 `json:"underlineThickness"`,
}

Glyph :: struct {
	unicode:     i32 `json:"unicode"`,
	// in ems
	advance:     f32 `json:"advance"`,
	// in ems
	planeBounds: struct {
		left:   f32 `json:"left"`,
		bottom: f32 `json:"bottom"`,
		right:  f32 `json:"right"`,
		top:    f32 `json:"top"`,
	},
	// in pixels
	atlasBounds: struct {
		left:   f32 `json:"left"`,
		bottom: f32 `json:"bottom"`,
		right:  f32 `json:"right"`,
		top:    f32 `json:"top"`,
	},
}

// TODO: implement :p
KernPair :: struct {}

