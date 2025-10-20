.PHONY: format lint all

all: lint format

format:
	@echo "Formatting..."
	@stylua init.lua > /dev/null
	@echo "✓ Formatted"

lint:
	@echo "Linting..."
	@luacheck init.lua > /dev/null
	@echo "✓ Linted"
