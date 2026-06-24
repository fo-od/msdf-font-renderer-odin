package artery_font

import "core:os"

ARTERY_FONT_HEADER_TAG :: "ARTERY/FONT\x00\x00\x00\x00\x00"
ARTERY_FONT_HEADER_VERSION :: u32(1)
ARTERY_FONT_HEADER_MAGIC_NO :: u32(0x4d276a5c)
ARTERY_FONT_FOOTER_MAGIC_NO :: u32(0x55ccb363)

ArteryFontHeader :: struct #packed {
	tag:               [16]u8,
	magic_no:          u32,
	version:           u32,
	flags:             u32,
	real_type:         u32,
	reserved:          [4]u32,
	metadata_format:   u32,
	metadata_length:   u32,
	variant_count:     u32,
	variants_length:   u32,
	image_count:       u32,
	images_length:     u32,
	appendix_count:    u32,
	appendices_length: u32,
	reserved2:         [8]u32,
}

ArteryFontFooter :: struct #packed {
	salt:      u32,
	magic_no:  u32,
	reserved:  [4]u32,
	total_len: u32,
	checksum:  u32,
}

FontVariantHeader :: struct #packed {
	flags:            u32,
	weight:           u32,
	codepoint_type:   u32,
	image_type:       u32,
	fallback_variant: u32,
	fallback_glyph:   u32,
	reserved:         [6]u32,
	metrics:          [32]f32,
	name_length:      u32,
	metadata_length:  u32,
	glyph_count:      u32,
	kern_pair_count:  u32,
}

ImageHeader :: struct #packed {
	flags:           u32,
	encoding:        u32,
	width:           u32,
	height:          u32,
	channels:        u32,
	pixel_format:    u32,
	image_type:      u32,
	row_length:      u32,
	orientation:     i32,
	child_images:    u32,
	texture_flags:   u32,
	reserved:        [3]u32,
	metadata_length: u32,
	data_length:     u32,
}

AppendixHeader :: struct #packed {
	metadata_length: u32,
	data_length:     u32,
}

@(private)
padded_length :: proc(n: u32) -> u32 {
	r := n
	if r & 3 != 0 {
		r += 4 - (r & 3)
	}
	return r
}

@(private)
padded_string_length :: proc(s: string) -> u32 {
	n := u32(len(s))
	return padded_length(n + u32(n > 0))
}

@(private)
read :: proc(file: ^os.File, dst: []byte, len: int) -> (read: int, err: os.Error) {
	read, err = os.read(file, dst)
	return
}

@(private)
read_exact :: proc(file: ^os.File, dst: rawptr, n: int, total_len: ^u32, checksum: ^u32) -> bool {
	tmp := make([]u8, n)
	read_count, err := read(file, tmp, n)
	if err != nil || read_count != n {
		return false
	}
	dst_arr := cast([^]u8)dst
	for i in 0 ..< n {
		dst_arr[i] = tmp[i]
		checksum^ = crc32Update(checksum^, tmp[i])
	}
	total_len^ += u32(n)
	delete(tmp)
	return true
}

@(private)
read_string :: proc(
	file: ^os.File,
	s: ^string,
	byte_len: u32,
	total_len: ^u32,
	checksum: ^u32,
) -> bool {
	if byte_len == 0 {
		s^ = ""
		return true
	}
	buf := make([]u8, int(byte_len) + 1)
	if !read_exact(file, rawptr(&buf[0]), len(buf), total_len, checksum) {
		return false
	}
	buf[int(byte_len)] = 0
	s^ = string(buf[:int(byte_len)])
	if rem := total_len^ & 3; rem != 0 {
		pad := int(4 - rem)
		dump := make([]u8, pad)
		defer delete(dump)
		if !read_exact(file, rawptr(&dump[0]), pad, total_len, checksum) {
			return false
		}
	}
	delete(buf)
	return true
}

decode :: proc(font: ^ArteryFont, file: ^os.File) -> bool {
	total_len := u32(0)
	checksum := crc32Init()

	header: ArteryFontHeader
	if !read_exact(file, rawptr(&header), size_of(ArteryFontHeader), &total_len, &checksum) {
		return false
	}
	if string(header.tag[:]) != ARTERY_FONT_HEADER_TAG ||
	   header.magic_no != ARTERY_FONT_HEADER_MAGIC_NO {
		return false
	}

	font.metadataFormat = cast(MetadataFormat)header.metadata_format
	if !read_string(file, &font.metadata, header.metadata_length, &total_len, &checksum) {
		return false
	}
	font.variants = make([]FontVariant, int(header.variant_count))
	font.images = make([]FontImage, int(header.image_count))
	font.appendices = make([]FontAppendix, int(header.appendix_count))

	prev_len := total_len
	for i in 0 ..< int(header.variant_count) {
		vh: FontVariantHeader
		if !read_exact(file, rawptr(&vh), size_of(FontVariantHeader), &total_len, &checksum) {
			return false
		}
		v := &font.variants[i]
		v.flags = vh.flags
		v.weight = vh.weight
		v.codepointType = cast(CodepointType)vh.codepoint_type
		v.imageType = cast(ImageType)vh.image_type
		v.fallbackVariant = vh.fallback_variant
		v.fallbackGlyph = vh.fallback_glyph
		v.metrics.fontSize = vh.metrics[0]
		v.metrics.distanceRange = vh.metrics[1]
		v.metrics.emSize = vh.metrics[2]
		v.metrics.ascender = vh.metrics[3]
		v.metrics.descender = vh.metrics[4]
		v.metrics.lineHeight = vh.metrics[5]
		v.metrics.underlineY = vh.metrics[6]
		v.metrics.underlineThickness = vh.metrics[7]
		v.metrics.distanceRangeMiddle = vh.metrics[8]
		for j in 0 ..< len(v.metrics.reserved) {
			v.metrics.reserved[j] = vh.metrics[9 + j]
		}
		if !read_string(file, &v.name, vh.name_length, &total_len, &checksum) {return false}
		if !read_string(
			file,
			&v.metadata,
			vh.metadata_length,
			&total_len,
			&checksum,
		) {return false}
		v.glyphs = make([]Glyph, int(vh.glyph_count))
		v.kernPairs = make([]KernPair, int(vh.kern_pair_count))
		if vh.glyph_count > 0 &&
		   !read_exact(
				   file,
				   rawptr(&v.glyphs[0]),
				   int(vh.glyph_count) * size_of(Glyph),
				   &total_len,
				   &checksum,
			   ) {
			return false
		}
		if vh.kern_pair_count > 0 &&
		   !read_exact(
				   file,
				   rawptr(&v.kernPairs[0]),
				   int(vh.kern_pair_count) * size_of(KernPair),
				   &total_len,
				   &checksum,
			   ) {
			return false
		}
	}
	if total_len - prev_len != header.variants_length {
		return false
	}

	prev_len = total_len
	for i in 0 ..< int(header.image_count) {
		ih: ImageHeader
		if !read_exact(file, rawptr(&ih), size_of(ImageHeader), &total_len, &checksum) {
			return false
		}
		im := &font.images[i]
		im.flags = ih.flags
		im.encoding = cast(ImageEncoding)ih.encoding
		im.width = ih.width
		im.height = ih.height
		im.channels = ih.channels
		im.pixelFormat = cast(PixelFormat)ih.pixel_format
		im.imageType = cast(ImageType)ih.image_type
		im.rawBinaryFormat.rowLength = ih.row_length
		im.rawBinaryFormat.orientation = cast(ImageOrientation)ih.orientation
		im.childImages = ih.child_images
		im.textureFlags = ih.texture_flags
		if !read_string(
			file,
			&im.metadata,
			ih.metadata_length,
			&total_len,
			&checksum,
		) {return false}
		im.data = make([]u8, int(ih.data_length))
		if ih.data_length > 0 &&
		   !read_exact(file, rawptr(&im.data[0]), int(ih.data_length), &total_len, &checksum) {
			return false
		}
		if rem := total_len & 3; rem != 0 {
			dump := make([]u8, int(4 - rem))
			defer delete(dump)
			if !read_exact(file, rawptr(&dump[0]), len(dump), &total_len, &checksum) {return false}
		}
	}
	if total_len - prev_len != header.images_length {
		return false
	}

	prev_len = total_len
	for i in 0 ..< int(header.appendix_count) {
		ah: AppendixHeader
		if !read_exact(file, rawptr(&ah), size_of(AppendixHeader), &total_len, &checksum) {
			return false
		}
		ap := &font.appendices[i]
		if !read_string(
			file,
			&ap.metadata,
			ah.metadata_length,
			&total_len,
			&checksum,
		) {return false}
		ap.data = make([]u8, int(ah.data_length))
		if ah.data_length > 0 &&
		   !read_exact(file, rawptr(&ap.data[0]), int(ah.data_length), &total_len, &checksum) {
			return false
		}
		if rem := total_len & 3; rem != 0 {
			dump := make([]u8, int(4 - rem))
			defer delete(dump)
			if !read_exact(file, rawptr(&dump[0]), len(dump), &total_len, &checksum) {return false}
		}
	}
	if total_len - prev_len != header.appendices_length {
		return false
	}

	footer: ArteryFontFooter
	if !read_exact(
		file,
		rawptr(&footer),
		size_of(ArteryFontFooter) - size_of(u32),
		&total_len,
		&checksum,
	) {
		return false
	}
	if footer.magic_no != ARTERY_FONT_FOOTER_MAGIC_NO {
		return false
	}
	final_checksum := checksum
	if !read_exact(file, rawptr(&footer.checksum), size_of(u32), &total_len, &checksum) {
		return false
	}
	return footer.checksum == final_checksum && total_len == footer.total_len
}

