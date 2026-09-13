## Builds simple, recognizable placeholder sprite textures from an in-code
## pixel pattern. No external image files. RefCounted (not Node) so it stays
## usable from a headless test with no scene tree.
class_name PlaceholderArt
extends RefCounted

## '.' = transparent, '#' = body, 'o' = accent, '-' = outline.
const HUMANOID: Array[String] = [
	"..####..",
	".#oooo#.",
	".#o..o#.",
	".#oooo#.",
	"..####..",
	".######.",
	"##.##.##",
	"##.##.##",
	".#....#.",
	"###..###",
]

const BLOB: Array[String] = [
	"........",
	"..####..",
	".######.",
	"#o####o#",
	"########",
	"########",
	"#.####.#",
	"..####..",
]

## Paints an ASCII grid into a nearest-neighbor-upscaled ImageTexture.
static func from_pattern(rows: Array[String], body: Color, accent: Color, scale: int = 4) -> ImageTexture:
	var height := rows.size()
	var width := rows[0].length()
	var image := Image.create_empty(width * scale, height * scale, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	var outline := body.darkened(0.55)
	for y in height:
		var line: String = rows[y]
		for x in line.length():
			var symbol := line[x]
			var color: Color
			match symbol:
				"#":
					color = body
				"o":
					color = accent
				"-":
					color = outline
				_:
					continue
			image.fill_rect(Rect2i(x * scale, y * scale, scale, scale), color)
	return ImageTexture.create_from_image(image)
