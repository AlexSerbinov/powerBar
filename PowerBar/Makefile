.PHONY: build install clean run test help

# Default target
help:
	@echo "🔧 PowerBar Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build     - Build PowerBar in release mode"
	@echo "  install   - Install PowerBar to /Applications"
	@echo "  run       - Build and run PowerBar"
	@echo "  clean     - Clean build artifacts"
	@echo "  test      - Run tests"
	@echo "  check     - Check if macmon is available"
	@echo "  help      - Show this help message"

# Build the application
build:
	@./build.sh

# Install to Applications folder
install: build
	@./install.sh

# Build and run directly
run: build
	@echo "🚀 Starting PowerBar..."
	@./.build/release/PowerBar

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf .build
	@echo "✅ Clean complete"

# Run tests
test:
	@echo "🧪 Running tests..."
	@swift test

# Check macmon availability
check:
	@echo "🔍 Checking macmon availability..."
	@if command -v macmon >/dev/null 2>&1; then \
		echo "✅ macmon is available"; \
		macmon --version; \
	else \
		echo "❌ macmon is not installed or not in PATH"; \
		echo "   Install it: brew install macmon"; \
	fi

# Quick development cycle
dev: clean build run 