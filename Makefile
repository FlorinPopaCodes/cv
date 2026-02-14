.PHONY: build watch clean setup release

PDF = cv.pdf
TEX = cv.tex

build: $(PDF)

$(PDF): $(TEX)
	tectonic $(TEX)

watch:
	@echo "Building initial PDF..."
	@tectonic $(TEX)
	@open $(PDF)
	@echo "Watching for changes... (Ctrl+C to stop)"
	@fswatch -o $(TEX) | while read; do \
		echo "Rebuilding..."; \
		tectonic $(TEX) && echo "Done." || echo "Build failed."; \
	done

clean:
	rm -f $(PDF) *.aux *.log *.out

release: $(PDF)
	gh release create $(shell date +%Y-%m-%d) $(PDF) --title "CV — $(shell date +%Y-%m-%d)" --notes "Built on $(shell date +%Y-%m-%d)" --latest --clobber

setup:
	@echo "Installing dependencies..."
	brew install tectonic fswatch
	@echo "Done. Run 'make watch' to start."
