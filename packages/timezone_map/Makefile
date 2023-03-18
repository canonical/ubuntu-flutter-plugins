all: png scalable

SVG = $(wildcard assets/src/*.svg)
png: $(SVG:assets/src/%.svg=assets/medium/%.png) $(SVG:assets/src/%.svg=assets/medium/2.0x/%.png)
scalable: $(SVG:assets/src/%.svg=assets/scalable/%.svg.vec)

assets/medium/%.png: assets/src/%.svg
	@mkdir -p assets/medium
	inkscape -w 960 -h 480 $< -o $@
	pngcrush -ow $@

assets/medium/2.0x/%.png: assets/src/%.svg
	@mkdir -p assets/medium/2.0x
	inkscape -w 1920 -h 960 $< -o $@
	pngcrush -ow $@

assets/scalable/%.svg.vec: assets/src/%.svg
	@mkdir -p assets/scalable
	dart run vector_graphics_compiler -i $< -o $@
